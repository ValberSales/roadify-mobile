# Requisitos

## 1\. Visão Geral do Sistema e Escopo Técnico

### 1.1 Propósito do Software

O **Roadify Mobile** é uma aplicação móvel desenvolvida em Flutter (para plataformas Android e iOS) voltada ao setor de engenharia de transportes e infraestrutura viária. O software transforma smartphones comerciais acoplados a suportes veiculares em estações multissensoriais de inspeção para **triagem rápida, contínua e de baixo custo de pavimentos asfálticos**.

### 1.2 Delimitação Rígida de Escopo

O escopo deste aplicativo móvel restringe-se estritamente à operação veicular de campo:

- **Dentro do Escopo:** Nivelamento físico e calibração angular do aparelho (Nível Bolha Digital); aquisição inercial contínua em alta frequência (100–200 Hz); geolocalização e velocidade instantânea (GPS); registro fotográfico de anomalias; telemetria de bateria; persistência local transacional no banco **Drift (SQLite)**; filtro exportador de arquivos tabulares em formato **CSV com delimitador ponto e vírgula (\*\***`;`\***\*)** e pacotes **ZIP**; e sincronização em segundo plano com a API RESTful do servidor.
- **Fora do Escopo:** Processamento pesado de sinal digital (DSP com filtros passa-baixa, passa-alta ou Butterworth), análise espectral por FFT, cálculo do índice de irregularidade proprietário, segmentação geodésica em SIG e geração cartográfica de mapas web. Todas estas rotinas são de responsabilidade exclusiva do **backend / servidor em nuvem**.

---

## 2\. Requisitos Funcionais (RF) e Não-Funcionais Atrelados (RNF)

Esta seção descreve cada funcionalidade do sistema e atrela diretamente a ela os atributos de qualidade, desempenho, usabilidade e restrições técnicas que devem ser satisfeitos.

---

### RF01 — Calibração e Nivelamento Angular com Nível Bolha Digital

O aplicativo deve fornecer uma interface visual de nível bolha digital com mira concêntrica que calcule e exiba em tempo real a inclinação tridimensional (_Pitch_ e _Roll_) do smartphone instalado no suporte veicular, permitindo aplicar tara angular para compensar a inclinação do para-brisa.

| Código RNF | Atributo             | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                                         |
| ---------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF01.1    | Desempenho / Fluidez | A animação gráfica do deslocamento da bolha e o cálculo trigonométrico devem operar a uma taxa mínima estável de 30 quadros por segundo (FPS), sem travamentos na interface.                          |
| RNF01.2    | Precisão Angular     | O algoritmo de fusão dos sensores inerciais (acelerômetro + filtro passa-baixa) deve assegurar resolução e precisão angular de ±0,1° em ambos os eixos transversais e longitudinais.                  |
| RNF01.3    | Tolerância Visual    | A interface gráfica deve apresentar feedback visual imediato (anel e fluido alterando a cor para Verde Esmeralda) quando o desvio angular estiver dentro da faixa de tolerância operacional (≤ 0,5°). |
| RNF01.4    | Persistência da Tara | Ao acionar o botão "Zerar / Tarar", os offsets angulares (θ_pitch, θ_roll) devem ser gravados em memória e persistidos nos metadados do ensaio para compensação das forças gravitacionais.            |

---

### RF02 — Parametrização e Configuração Pré-Ensaio

O sistema deve disponibilizar um formulário de parametrização prévia para registrar as informações do veículo, odômetro inicial e taxas de amostragem antes do início de qualquer ciclo de medição na rodovia.

| Código RNF | Atributo                     | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                                                               |
| ---------- | ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF02.1    | Persistência de Preferências | Os dados inseridos (veículo padrão, placa, taxa do acelerômetro e taxa de GPS) devem ser mantidos localmente no dispositivo (via `SharedPreferences`), evitando que o operador redigite os mesmos parâmetros a cada coleta. |
| RNF02.2    | Validação Estrita de Entrada | Os campos de odômetro, frequências (`txaccel`, `txgpsi`) e metros devem aceitar estritamente valores numéricos válidos e positivos, bloqueando submissões com dados inconsistentes ou campos vazios.                        |
| RNF02.3    | Telemetria Automática        | O sistema deve capturar automaticamente em baixo nível os metadados de hardware do aparelho: fabricante (vendor), modelo comercial, percentual inicial de bateria e temperatura da bateria em graus Celsius.                |

---

### RF03 — Seleção e Gerenciamento de Sensores

O sistema deve permitir que o operador selecione quais sensores periféricos e recursos de mídia serão ativados para a coleta (Acelerômetro, Giroscópio, GPS, Câmera e Áudio).

| Código RNF | Atributo                | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                                         |
| ---------- | ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF03.1    | Integridade Operacional | O Acelerômetro e o GPS são mandatórios para validação de qualquer ensaio viário. Os módulos de Câmera e Áudio são facultativos e sua ausência de permissão não deve impedir a coleta inercial básica. |
| RNF03.2    | Gestão de Permissões    | A solicitação de permissões (Runtime Permissions) para Localização precisa, Acesso em Segundo Plano e Câmera deve ocorrer de forma contextualizada e guiada com mensagens em português claro.         |

---

### RF04 — Execução de Coleta e Telemetria em Pista (Cockpit HUD)

O aplicativo deve fornecer uma interface de condução (_Cockpit HUD_) que apresente telemetria contínua durante o percurso (cronômetro, velocímetro digital, distância acumulada, osciloscópio dos eixos X, Y, Z) e botão para captura de fotos de anomalias na pista.

| Código RNF | Atributo                        | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                              |
| ---------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| RNF04.1    | Taxa de Amostragem Inercial     | O subsistema de captura deve sustentar taxas configuráveis de 100 Hz ou 200 Hz para o acelerômetro e giroscópio sem perda de amostras (dropped frames).                                    |
| RNF04.2    | Gerenciamento de Memória        | O gráfico osciloscópico em tempo real deve utilizar uma estrutura de buffer circular fixo (máximo de 50 a 100 amostras) para evitar sobrecarga de memória RAM e vazamentos (memory leaks). |
| RNF04.3    | Prevenção de Suspensão          | A aplicação deve forçar a tela a permanecer permanentemente ativa (Wakelock) durante todo o período em que a coleta estiver no estado `GRAVANDO`.                                          |
| RNF04.4    | Latência de Captura Fotográfica | O acionamento do botão de foto rápida deve registrar e salvar a imagem em resolução otimizada em menos de 500 ms, executado em thread desacoplada sem interromper o fluxo inercial.        |

---

### RF05 — Persistência Estruturada Local via Banco Drift (SQLite)

Todos os dados brutos inerciais, geográficos e metadados de condução devem ser persistidos localmente no dispositivo utilizando o motor de banco de dados relacional **Drift (SQLite)**.

| Código RNF | Atributo                    | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                                                                                          |
| ---------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| RNF05.1    | Gravação em Lote (Batching) | A ingestão de leituras inerciais em alta taxa (200 amostras/segundo) deve utilizar buffers periódicos em memória e inserções atômicas em lote (`batch.insertAll`) a cada 1 a 2 segundos, evitando saturação de disco.                                  |
| RNF05.2    | Resiliência a Falhas ACID   | O esquema relacional e as transações do banco devem garantir que, em caso de encerramento abrupto do aplicativo (perda de bateria, choque mecânico ou superaquecimento), todas as amostras gravadas até o último lote sejam preservadas sem corrupção. |
| RNF05.3    | Reatividade via Streams     | As consultas da interface gráfica aos ensaios salvos devem utilizar os Streams nativos do Drift (`watch()`), atualizando a tela instantaneamente quando uma nova coleta for finalizada.                                                                |

---

### RF06 — Geração de Arquivos Tabulares e Compactação (CsvExportFilterService)

O aplicativo deve conter um serviço especializado de filtragem e exportação (`CsvExportFilterService`) capaz de extrair os registros do banco Drift e gerar os arquivos em texto plano no formato CSV e pacotes ZIP para distribuição.

| Código RNF | Atributo                         | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                                                     |
| ---------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF06.1    | Delimitador Padronizado          | Todos os arquivos CSV gerados devem utilizar obrigatoriamente o ponto e vírgula (`;`) como separador de colunas e codificação textual UTF-8, garantindo compatibilidade com ferramentas de planilha e o servidor. |
| RNF06.2    | Estrutura de Diretório do Ensaio | Cada ensaio exportado deve conter exatamente: `aceleracao.csv`, `localizacao.csv`, `config.csv` e a pasta de fotos vinculadas.                                                                                    |
| RNF06.3    | Compactação Atômica em ZIP       | O sistema deve compactar a pasta do ensaio em um arquivo `.zip` íntegro, gerando hash de validação antes da transmissão para a nuvem.                                                                             |

---

### RF07 — Gerenciamento Local de Ensaios Gravados (Aba Dados)

O aplicativo deve listar todos os ensaios realizados e armazenados na memória do smartphone, disponibilizando busca, informações resumidas (distância, duração, quantidade de pontos, status de envio), exclusão e compartilhamento pelo sistema operacional.

| Código RNF | Atributo                 | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                          |
| ---------- | ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF07.1    | Performance de Listagem  | A listagem de ensaios deve carregar de forma instantânea através de paginação ou lazy loading, suportando mais de 500 coletas salvas sem travamento da rolagem.                        |
| RNF07.2    | Modal de Detalhes        | A aplicação deve fornecer um modal deslizante (bottom sheet) detalhando odômetro, horários de início/fim, consumo de bateria e mapa estático da rota percorrida.                       |
| RNF07.3    | Exclusão com Confirmação | A exclusão física de ensaios do disco e do banco Drift deve exigir confirmação explícita do usuário em caixa de diálogo (AlertDialog) para prevenir perda acidental de dados de campo. |

---

### RF08 — Sincronização em Nuvem via API RESTful (Upload)

O sistema deve disponibilizar funcionalidade de transmissão de dados para o servidor backend através de requisições HTTP RESTful, permitindo envio sob demanda pelo usuário ou sincronização automática quando conectado a redes Wi-Fi.

| Código RNF | Atributo                            | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                                              |
| ---------- | ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF08.1    | Transmissão Multipart em Background | O envio dos pacotes do ensaio (arquivos CSV ou ZIP) deve ocorrer via requisições HTTP `POST` multipart, exibindo porcentagem de progresso da transferência na interface.                                   |
| RNF08.2    | Feedback de Status Reativo          | O status de cada ensaio deve atualizar seu estado na interface: Pendente de Envio (ícone âmbar), Enviando... (indicador de progresso circular) e Sincronizado (selo verde com data e hora da confirmação). |
| RNF08.3    | Política de Retentativa             | Em caso de oscilação de sinal 4G/5G durante o envio, o sistema deve interromper a transferência sem corromper o ensaio local e permitir retomada posterior.                                                |

---

### RF09 — Autenticação de Usuários e Gestão de Sessão Segura

O aplicativo deve fornecer interfaces de login e registro de operador, permitindo acesso seguro às funcionalidades do sistema e vinculando as coletas ao identificador do vistoriador autenticado.

| Código RNF | Atributo                              | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                                    |
| ---------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| RNF09.1    | Validação de Formulário               | Validação reativa de campos de e-mail (expressão regular RFC 5322) e senha (mínimo de 6 caracteres), além de bloqueio de submissão dupla em caso de toques repetidos.                            |
| RNF09.2    | Armazenamento Criptografado de Tokens | O token de autenticação JWT retornado pela API deve ser armazenado exclusivamente no armazenamento seguro do sistema operacional (`flutter_secure_storage` via Android Keystore e iOS Keychain). |
| RNF09.3    | Interceptor de Requisições            | O cliente de rede (`Dio`) deve injetar automaticamente o cabeçalho `Authorization: Bearer <TOKEN>` em todas as rotas protegidas da API.                                                          |

---

### RF10 — Configurações Gerais do Aplicativo e Preferências

O sistema deve fornecer uma tela centralizada de configurações para controle de aparência, servidor de destino e preferências operacionais.

| Código RNF | Atributo                     | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                |
| ---------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF10.1    | Alternância Reativa de Temas | O usuário deve conseguir alternar dinamicamente entre Modo Claro, Modo Escuro ou Padrão do Sistema, com aplicação imediata em toda a árvore de widgets sem recarregar o app. |
| RNF10.2    | Configuração de Endpoint     | O sistema deve permitir configurar e testar a URL base da API RESTful do servidor, validando o protocolo (`http://` ou `https://`) e sintaxe de rede.                        |
| RNF10.3    | Suporte a Idiomas (i18n)     | A interface deve permitir a seleção de idioma entre Português, Inglês e Espanhol, com atualização em tempo real dos textos do sistema.                                       |

---

### RF11 — Overview Executivo e Diagnóstico de Armazenamento (HomeScreen)

A Tela Inicial do aplicativo deve funcionar como painel de controle executivo, apresentando indicadores consolidados das últimas coletas, status de sincronização, diagnóstico de espaço interno e atalho direto para nova medição.

| Código RNF | Atributo                             | Descrição do Requisito Não-Funcional Atrelado                                                                                                                                                 |
| ---------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RNF11.1    | Agregação em Tempo Real              | A contagem de ensaios gravados, total de quilômetros medidos e ensaios pendentes de envio devem ser calculados de forma assíncrona sem travar a inicialização do app.                         |
| RNF11.2    | Diagnóstico Preventivo de Disco      | A tela deve calcular a porcentagem e espaço livre em megabytes (MB) ou gigabytes (GB) disponíveis na memória interna, emitindo alerta visual quando a capacidade livre for inferior a 500 MB. |
| RNF11.3    | Acesso Rápido de Alta Acessibilidade | O botão principal de ação (CTA) "Nova Coleta" deve possuir tamanho mínimo de toque de 56 pt e alto contraste para fácil acionamento em suporte veicular.                                      |

---

## 3\. Requisitos de Sistema (RS) — Requisitos Não-Funcionais Globais

Os Requisitos de Sistema definem as restrições arquiteturais, tecnológicas, de segurança e ambientais aplicáveis a todo o ecossistema do Roadify Mobile:

```plain
flowchart TD
subgraph RS_Global ["Requisitos de Sistema (RS)"]
RS01["RS01: Flutter 3.x / Dart 3.x<br/>(Android 8+ & iOS 15+)"]
RS02["RS02: Daylight Light Mode<br/>(Alto Contraste Solar)"]
RS03["RS03: Pill-Shaped Floating Dock<br/>(Galaxy OneUI / iOS)"]
RS04["RS04: Arquitetura Offline-First<br/>(Autonomia 100% em Pista)"]
RS05["RS05: Offloading Computacional<br/>(Zero DSP pesado no Mobile)"]
RS06["RS06: Eficiência Térmica e CPU<br/>(&le; 15% em 200 Hz)"]
RS07["RS07: Persistência Drift SQLite<br/>(Batch Transactions ACID)"]
RS08["RS08: Exportação CSV (;)<br/>(Codificação UTF-8)"]
RS09["RS09: Internacionalização i18n<br/>(PT, EN, ES)"]
RS10["RS10: Criptografia e Segurança<br/>(Keystore, Keychain, TLS 1.3)"]
end
```

---

### RS01 — Plataforma Tecnológica e Compatibilidade

- **Descrição:** A aplicação deve ser construída exclusivamente no framework **Flutter 3.x+** e linguagem **Dart 3.x+**, com compilação nativa para as plataformas móveis:
    - **Android:** Versão mínima Android 8.0 Oreo (API Level 26) ou superior.
    - **iOS:** Versão mínima iOS 15.0 ou superior.
- **Justificativa:** Garantir interoperabilidade multissensorial com bibliotecas modernas de baixo nível e manter o mesmo código-fonte em ambas as lojas oficiais (Google Play e Apple App Store).

---

### RS02 — Usabilidade Diurna e Ergonomia Visual (Daylight Light Mode)

- **Descrição:** O design visual padrão do sistema é estritamente **Modo Claro (Light Mode)** de alto contraste fotométrico.
    - Cores de Fundo: Branco puro (`#FFFFFF`) e Cinza Claro (`#F8FAFC`).
    - Cor Primária Institucional: Verde Petróleo / Floresta (`#134E3F` e `#1B5E45`).
    - Cor Secundária / Destaque: Verde Limão Técnico (`#A3E635` e `#84CC16`).
    - Tipografia: Família **Inter** (`GoogleFonts.inter`) com pesos variando de Regular (400) a Bold (700).
- **Justificativa:** O aplicativo é operado predominantemente no para-brisa de automóveis durante o dia, onde reflexos e luz solar direta exigem alto contraste e legibilidade imediata.

---

### RS03 — Navegação por Barra Flutuante Pill-Shaped Dock (Galaxy OneUI / iOS)

- **Descrição:** A barra de navegação global inferior deve ser implementada como um componente flutuante desacoplado com formato de pílula (`border-radius: 32px`), com elevação de sombra suave e efeito translúcido (_frosted glass_ via `BackdropFilter` com desfoque de 20px).
- **Atalhos Mandatórios (5 Abas Fixas):**
    1. `Início` (Ícone de casa / Dashboard executivo)
    2. `Coleta` (Ícone de velocímetro / Formulário e cockpit de condução)
    3. `Sensores` (Ícone de osciloscópio / Nível bolha e leitura inercial)
    4. `Dados` (Ícone de pasta / Listagem de arquivos locais e exportação)
    5. `Config` (Ícone de engrenagem / Temas, rede e preferências)

---

### RS04 — Princípio Offline-First Absoluto

- **Descrição:** Nenhuma funcionalidade de calibração de sensores, parametrização de veículos, medição inercial, gravação em banco relacional ou exportação local de arquivos pode depender de conectividade com a internet ou cobertura de redes celulares.
- **Justificativa:** A malha rodoviária frequentemente corta áreas remotas sem cobertura de dados 3G/4G/5G. O sistema deve operar com autonomia completa em campo.

---

### RS05 — Desacoplamento Arquitetural e Offloading Computacional

- **Descrição:** É estritamente vedada a execução de cálculos pesados de processamento digital de sinais (DSP, filtros passa-baixa analíticos, algoritmos FFT e segmentações geoespaciais de SIG) dentro do processador do smartphone.
- **Justificativa:** O smartphone funciona como coletor confiável (_data logger_). Algoritmos matemáticos de sinal consomem intensamente a CPU móvel, provocando superaquecimento no suporte e esgotamento rápido da bateria.

---

### RS06 — Eficiência Térmica, de CPU e de Bateria

- **Descrição:** Durante a execução contínua de um ensaio a 200 Hz com tela ligada, gravação em banco e processamento de GPS, o consumo médio de processamento da aplicação não deve ultrapassar **15% da capacidade média da CPU** do dispositivo.
- **Justificativa:** A exposição contínua do aparelho aos raios solares no para-brisa pode desencadear o desligamento térmico de emergência do sistema operacional (_thermal throttling/thermal shutdown_).

---

### RS07 — Persistência Relacional Tipada com Drift (SQLite)

- **Descrição:** O motor principal de persistência estruturada do aplicativo é o banco de dados **Drift**, baseado no SQLite, utilizando tabelas fortemente tipadas (`RunsTable`, `SensorReadingsTable`, `GpsPointsTable`), migrações controladas e compilação de código estático via `drift_dev`.
- **Justificativa:** Evita corrupção de arquivos semi-escritos em disco e permite consultas instantâneas e reativas para relatórios e agregações na UI.

---

### RS08 — Padronização de Saída Tabular (CSV com Delimitador `;`)

- **Descrição:** Toda e qualquer geração de arquivo tabular em texto plano executada pelo `CsvExportFilterService` deve adotar obrigatoriamente:
    - Delimitador de colunas: **Ponto e vírgula (\*\***`;`\***\*)**.
    - Separador decimal numérico: Ponto (`.`).
    - Formato de data e hora: Padrão ISO 8601 estendido (`yyyy-MM-dd HH:mm:ss.SSS`).
    - Codificação de caracteres: **UTF-8 sem BOM**.
- **Justificativa:** Compatibilidade com o backend web do Roadify e facilidade de abertura direta em softwares de engenharia no Brasil sem conflitos de vírgula decimal.

---

### RS09 — Internacionalização Nativa (i18n)

- **Descrição:** Todas as cadeias de texto da interface, rótulos de botões, mensagens de erro e diálogos devem ser externalizados em arquivos de catálogo `.arb` utilizando o pacote oficial `flutter_localizations` e `intl`.
- **Idiomas Suportados:** Português do Brasil (`pt_BR` - padrão), Inglês (`en_US`) e Espanhol (`es_ES`).

---

### RS10 — Criptografia, Segurança e Privacidade de Credenciais

- **Descrição:** Tokens de acesso JWT, chaves de API e credenciais de login devem ser armazenados com criptografia de hardware gerenciada pelo sistema operacional (`flutter_secure_storage` com AES-GCM no Android Keystore e Keychain no iOS). Todas as transmissões com a nuvem devem ocorrer exclusivamente por canal seguro **HTTPS / TLS 1.3**.

---

## 4\. Dicionário Técnico dos Arquivos Exportados (CSV)

### 4.1 Arquivo `aceleracao.csv`

Armazena a série temporal inercial bruta de acelerações e giroscópio.

- **Delimitador:** `;` | **Codificação:** UTF-8
- **Especificação dos Campos:**
    1. `timestamp` (String): Data e hora no formato `yyyy-MM-dd HH:mm:ss.SSS`.
    2. `accel_x` (Float, 3 decimais): Aceleração linear transversal em m/s².
    3. `accel_y` (Float, 3 decimais): Aceleração linear longitudinal em m/s².
    4. `accel_z` (Float, 3 decimais): Aceleração linear vertical em m/s².
    5. `gyro_x` (Float, 3 decimais): Velocidade angular no eixo X em rad/s.
    6. `gyro_y` (Float, 3 decimais): Velocidade angular no eixo Y em rad/s.
    7. `gyro_z` (Float, 3 decimais): Velocidade angular no eixo Z em rad/s.

---

### 4.2 Arquivo `localizacao.csv`

Armazena a trajetória espacial e dinâmica de condução obtida pelos satélites.

- **Delimitador:** `;` | **Codificação:** UTF-8
- **Especificação dos Campos:**
    1. `timestamp` (String): Data e hora da fixação satelital (`yyyy-MM-dd HH:mm:ss.SSS`).
    2. `latitude` (Float, 6 decimais): Latitude em graus decimais (Datum WGS84).
    3. `longitude` (Float, 6 decimais): Longitude em graus decimais (Datum WGS84).
    4. `velocidade_kmh` (Float, 1 decimal): Velocidade instantânea em km/h.
    5. `precisao_m` (Float, 1 decimal): Raio de precisão horizontal estimada em metros.

---

### 4.3 Arquivo `config.csv`

Metadados consolidados de instrumentação, calibração angular e veículo do ensaio.

- **Delimitador:** `;` | **Codificação:** UTF-8
- **Estrutura Chave/Valor:**
    - `vendor`: Fabricante do smartphone.
    - `model`: Modelo de hardware do smartphone.
    - `phone_orientation`: Modo de fixação (`Portrait` ou `Landscape`).
    - `vehicle`: Identificação textual do veículo utilizado no ensaio.
    - `odometer_km`: Quilometragem inicial do veículo.
    - `sample_rate_accel_hz`: Frequência inercial configurada (ex: 200).
    - `sample_rate_gps_ms`: Taxa de leitura do GPS em milissegundos (ex: 1000).
    - `segment_interval_meters`: Intervalo configurado para gravação métrica.
    - `battery_level_start`: Porcentagem da bateria no início do ensaio.
    - `battery_temp_start`: Temperatura da bateria em °C no início do ensaio.
    - `battery_level_end`: Porcentagem da bateria no encerramento.
    - `battery_temp_end`: Temperatura da bateria em °C no encerramento.
    - `total_distance_gps_km`: Distância final acumulada calculada via GPS.
    - `level_pitch_offset_deg`: Ângulo de tara de inclinação longitudinal compensado.
    - `level_roll_offset_deg`: Ângulo de tara de inclinação transversal compensado.

---

## 5\. Matriz de Rastreabilidade (RF × RNF × RS)

| Requisito Funcional (RF)           | Requisitos Não-Funcionais Atrelados (RNF) | Requisitos de Sistema Relacionados (RS) |
| ---------------------------------- | ----------------------------------------- | --------------------------------------- |
| RF01 — Nível Bolha Digital         | RNF01.1, RNF01.2, RNF01.3, RNF01.4        | RS01, RS02, RS04, RS06                  |
| RF02 — Parametrização Pré-Ensaio   | RNF02.1, RNF02.2, RNF02.3                 | RS01, RS02, RS04                        |
| RF03 — Seleção de Sensores         | RNF03.1, RNF03.2                          | RS01, RS04, RS06                        |
| RF04 — Execução de Coleta (HUD)    | RNF04.1, RNF04.2, RNF04.3, RNF04.4        | RS01, RS02, RS04, RS05, RS06            |
| RF05 — Persistência Drift (SQLite) | RNF05.1, RNF05.2, RNF05.3                 | RS01, RS04, RS06, RS07                  |
| RF06 — Filtro CSV e Pacote ZIP     | RNF06.1, RNF06.2, RNF06.3                 | RS01, RS04, RS08                        |
| RF07 — Gestão Local de Ensaios     | RNF07.1, RNF07.2, RNF07.3                 | RS01, RS02, RS03, RS04, RS07            |
| RF08 — Sincronização API RESTful   | RNF08.1, RNF08.2, RNF08.3                 | RS01, RS05, RS08, RS10                  |
| RF09 — Autenticação e Sessão       | RNF09.1, RNF09.2, RNF09.3                 | RS01, RS02, RS10                        |
| RF10 — Configurações e Temas       | RNF10.1, RNF10.2, RNF10.3                 | RS01, RS02, RS03, RS09, RS10            |
| RF11 — Overview e Storage (Home)   | RNF11.1, RNF11.2, RNF11.3                 | RS01, RS02, RS03, RS04, RS07            |
