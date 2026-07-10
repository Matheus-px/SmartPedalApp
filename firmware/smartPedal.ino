#include "driver/i2s.h"
#include <math.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "USB.h" // Adicionado para controle nativo do USB

// ==========================================
// PINOS E DEFINIÇÕES DE HARDWARE
// ==========================================

// --- VBUS SENSE --- //
#define VBUS_SENSE_PIN 35 // Pino para detecção do cabo USB

// --- PINOS I2S (ÁUDIO) --- //
#define PIN_BCK   15
#define PIN_WS    6
#define PIN_MCLK  14
#define PIN_DIN   12
#define PIN_DOUT  7

// --- PINOS I2C (OLED) --- //
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define I2C_SDA_PIN 8
#define I2C_SCL_PIN 3
#define OLED_RESET -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// --- PINOS ENCODER --- //
#define CLK_PIN 46
#define DT_PIN 9
#define SW_PIN 10 // Reservado para uso futuro

// --- LIMITES DE SINAL --- //
#define SAMPLE_MAX  ( 2147483647.0f)
#define SAMPLE_MIN  (-2147483648.0f)
#define TWO_PI      (6.28318530718f)

// ==========================================
// VARIÁVEIS GLOBAIS
// ==========================================

// --- CONTROLE DE VOLUME (ENCODER) ---
volatile int encoderValue = 100; // Começa em 100 (Volume normal = 1.0f)
volatile int lastClkState = LOW;
float master_volume = 1.0f; // Multiplicador (0.0f a 1.5f)
bool ui_needs_update = false;

// --- ESTRUTURA DOS EFEITOS ---
// 1: Delay | 2: Drive | 3: EQ | 4: Fuzz | 5: Tremolo
int effect_order[5]  = {1, 2, 3, 4, 5}; 
bool effect_active[5] = {false, false, false, false, false};
const char* effect_names[] = {"", "Delay", "Drive", "EQ", "Fuzz", "Tremolo"};

// 1. DELAY
#define DELAY_BUFFER_SIZE 24000
#define FEEDBACK_AMOUNT 0.5f    
#define MIX_WET         0.6f    
#define MIX_DRY         0.8f    
float delay_buffer[DELAY_BUFFER_SIZE];
int delay_index = 0;

// 2. DRIVE
#define DRIVE_GAIN 5.0f

// 3. EQUALIZADOR SIMPLES
#define EQ_LOW_GAIN   1.5f 
#define EQ_MID_GAIN   0.8f
#define EQ_HIGH_GAIN  1.3f
float lp_low[2]  = {0, 0};
float lp_high[2] = {0, 0};

// 4. FUZZ
#define FUZZ_GAIN 20.0f

// 5. TREMOLO
#define TREMOLO_RATE  5.0f
#define TREMOLO_DEPTH 0.8f
float lfo_phase = 0.0f;    
const float phase_increment = (TWO_PI * TREMOLO_RATE) / 96000.0f;

// ==========================================
// INTERRUPÇÃO DO ENCODER
// ==========================================

void IRAM_ATTR readEncoder() {
    static unsigned long lastInterruptTime = 0;
    unsigned long interruptTime = micros(); 
    
    if (interruptTime - lastInterruptTime > 5000) {
        if (digitalRead(DT_PIN) != digitalRead(CLK_PIN)) {
            if (encoderValue < 150) encoderValue += 5;
        } else {
            if (encoderValue > 0) encoderValue -= 5;
        }
    }
    lastInterruptTime = interruptTime;
}

// ==========================================
// FUNÇÕES DOS EFEITOS (DSP)
// ==========================================

inline float fx_delay(float in) {
    float delayed = delay_buffer[delay_index];
    float to_buffer = in + (delayed * FEEDBACK_AMOUNT);
    
    if (to_buffer > 1.0f) to_buffer = 1.0f;   
    if (to_buffer < -1.0f) to_buffer = -1.0f; 
    
    delay_buffer[delay_index] = to_buffer;
    delay_index++;
    if (delay_index >= DELAY_BUFFER_SIZE) delay_index = 0;
    
    return (in * MIX_DRY) + (delayed * MIX_WET);
}

inline float fx_drive(float in) {
    in *= DRIVE_GAIN;
    return in / (1.0f + abs(in)); 
}

inline float fx_eq(float in, int ch) {
    lp_low[ch] += 0.038f * (in - lp_low[ch]);   
    lp_high[ch] += 0.282f * (in - lp_high[ch]); 

    float lows = lp_low[ch];
    float highs = in - lp_high[ch];
    float mids = in - lows - highs; 

    return (lows * EQ_LOW_GAIN) + (mids * EQ_MID_GAIN) + (highs * EQ_HIGH_GAIN);
}

inline float fx_fuzz(float in) {
    in *= FUZZ_GAIN;
    if (in > 1.0f) return 1.0f;
    if (in < -1.0f) return -1.0f;
    return in;
}

inline float fx_tremolo(float in) {
    float lfo = sin(lfo_phase);
    lfo_phase += phase_increment;
    if (lfo_phase >= TWO_PI) lfo_phase -= TWO_PI;
    
    float modulation = (lfo + 1.0f) * 0.5f;
    float amplitude = (1.0f - TREMOLO_DEPTH) + (TREMOLO_DEPTH * modulation);
    
    return in * amplitude;
}

// ==========================================
// DISPLAY E SERIAL
// ==========================================

void updateDisplay() {
    display.clearDisplay(); 
    display.setCursor(0, 0); 
    display.setTextSize(1); 
    display.setTextColor(SSD1306_WHITE); 
    
    display.print(F("FX CHAIN"));
    
    display.setCursor(70, 0);
    display.print(F("VOL:"));
    display.print(encoderValue);
    display.println(F("%"));
    
    display.drawLine(0, 10, 127, 10, SSD1306_WHITE); 
    display.setCursor(0, 16); 
    
    for (int i = 0; i < 5; i++) {
        int id = effect_order[i];
        if (id >= 1 && id <= 5) {
            display.print(effect_active[i] ? F("[ON] ") : F("[  ] "));
            display.println(effect_names[id]);
        }
    }
    display.display(); 
}

void processSerialCommands() {
    static int temp_order[5];
    static bool temp_active[5];
    static int cmd_index = 0;

    while (Serial.available() > 0) {
        String line = Serial.readStringUntil('\n');
        line.trim();

        if (line == "END") {
            for (int i = 0; i < 5; i++) {
                effect_order[i] = temp_order[i];
                effect_active[i] = temp_active[i];
            }
            cmd_index = 0; 
            ui_needs_update = true;
            Serial.println(">>> Cadeia atualizada via Serial!");
        } else if (line.length() > 0 && cmd_index < 5) {
            int id, active;
            if (sscanf(line.c_str(), "%d , %d", &id, &active) == 2) {
                temp_order[cmd_index] = id;
                temp_active[cmd_index] = (active == 1);
                cmd_index++;
            }
        }
    }
}

// ==========================================
// SETUP
// ==========================================

void setup_i2s() {
    i2s_config_t cfg = {
        .mode                 = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX | I2S_MODE_TX),
        .sample_rate          = 48000,
        .bits_per_sample      = I2S_BITS_PER_SAMPLE_32BIT,
        .channel_format       = I2S_CHANNEL_FMT_RIGHT_LEFT,
        .communication_format = I2S_COMM_FORMAT_STAND_I2S,
        .intr_alloc_flags     = ESP_INTR_FLAG_LEVEL1,
        .dma_buf_count        = 8,
        .dma_buf_len          = 128,
        .use_apll             = false,
        .tx_desc_auto_clear   = true,
        .fixed_mclk           = 0,
        .mclk_multiple        = I2S_MCLK_MULTIPLE_256
    };
    i2s_pin_config_t pins = {
        .mck_io_num   = PIN_MCLK,
        .bck_io_num   = PIN_BCK,
        .ws_io_num    = PIN_WS,
        .data_out_num = PIN_DOUT,
        .data_in_num  = PIN_DIN
    };
    i2s_driver_install(I2S_NUM_0, &cfg, 0, NULL);
    i2s_set_pin(I2S_NUM_0, &pins);
}

void setup() {
    // Inicialização do VBUS Sense
    pinMode(VBUS_SENSE_PIN, INPUT);
    if (digitalRead(VBUS_SENSE_PIN) == HIGH) {
        USB.begin(); // Habilita a interface se já estiver plugado ao ligar
    }

    Serial.begin(115200);
    
    pinMode(CLK_PIN, INPUT_PULLUP);
    pinMode(DT_PIN, INPUT_PULLUP);
    pinMode(SW_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(CLK_PIN), readEncoder, FALLING);

    Wire.begin(I2C_SDA_PIN, I2C_SCL_PIN);
    if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
        Serial.println(F("FALHA: Display SSD1306 não encontrado!"));
    }
    updateDisplay();

    for (int i = 0; i < DELAY_BUFFER_SIZE; i++) delay_buffer[i] = 0.0f;
    setup_i2s();
    
    Serial.println("Roteamento Multi-Efeitos I2S Rodando!");
}

// ==========================================
// LOOP PRINCIPAL
// ==========================================

void loop() {
    // --- GERENCIAMENTO DINÂMICO DO VBUS (USB) ---
    static bool cabo_conectado = (digitalRead(VBUS_SENSE_PIN) == HIGH);
    bool estado_vbus_atual = digitalRead(VBUS_SENSE_PIN);
    
    if (estado_vbus_atual && !cabo_conectado) {
        USB.begin(); 
        cabo_conectado = true;
    } 
    else if (!estado_vbus_atual && cabo_conectado) {
        // Desconecta a interface USB quando o cabo é removido
        // Nota: A função end() pode não estar mapeada em todas as versões do Core Arduino, 
        // mas é o padrão para resetar o PHY interno do ESP32.
        #if defined(USBCON) || defined(USE_TINYUSB)
        USB.end(); 
        #endif
        cabo_conectado = false;
    }

    // --- RESTANTE DA LÓGICA ---
    processSerialCommands();

    static int lastEncoderValue = 100;
    if (encoderValue != lastEncoderValue) {
        master_volume = encoderValue / 100.0f;
        lastEncoderValue = encoderValue;
        ui_needs_update = true;
    }

    if (ui_needs_update) {
        updateDisplay();
        ui_needs_update = false;
    }

    int32_t buf[128];
    size_t  bytes_read = 0;
    size_t  bytes_written = 0;

    esp_err_t result = i2s_read(I2S_NUM_0, buf, sizeof(buf), &bytes_read, pdMS_TO_TICKS(100));
    
    if (result == ESP_OK && bytes_read > 0) {
        int samples = bytes_read / sizeof(int32_t);

        // Processa pulando de 2 em 2 (i = Canal L, i+1 = Canal R)
        for (int i = 0; i < samples; i += 2) {
            
            // ÍNDICE PAR (i) = Canal Esquerdo (L) -> Continua LIMPO (Dry)
            float sample_clean = (float)buf[i] / SAMPLE_MAX; 
            
            // ÍNDICE ÍMPAR (i+1) = Canal Direito (R) -> Vai sofrer os EFEITOS (Wet)
            float sample_fx = (float)buf[i+1] / SAMPLE_MAX; 

            // Aplica os efeitos APENAS no canal R (sample_fx)
            for (int e = 0; e < 5; e++) {
                if (!effect_active[e]) continue;
                switch (effect_order[e]) {
                    case 1: sample_fx = fx_delay(sample_fx); break;
                    case 2: sample_fx = fx_drive(sample_fx); break;
                    case 3: sample_fx = fx_eq(sample_fx, 1); break; // Usa o canal 1 interno do EQ (opcional)
                    case 4: sample_fx = fx_fuzz(sample_fx); break;
                    case 5: sample_fx = fx_tremolo(sample_fx); break;
                }
            }
            
            // Junta o canal R com efeitos (sample_fx) e o canal L limpo (sample_clean)
            // Multiplicamos por 0.5f para evitar distorção digital (clipping) ao somar os dois
            float f_out = (sample_fx + sample_clean) * 0.5f;

            // Aplica o Volume Geral controlado pelo encoder
            f_out *= master_volume;
            
            // Limitador de segurança rígido
            if (f_out > 1.0f) f_out = 1.0f;
            if (f_out < -1.0f) f_out = -1.0f;

            // Converte de volta para inteiro de 32 bits
            int32_t out_sample = (int32_t)(f_out * SAMPLE_MAX);
            
            // Envia o sinal combinado (Mono) para ambas as saídas físicas do I2S
            buf[i]   = out_sample; // Saída L recebe o Mono final
            buf[i+1] = out_sample; // Saída R recebe o Mono final
        }

        i2s_write(I2S_NUM_0, buf, bytes_read, &bytes_written, pdMS_TO_TICKS(100));
    }
}