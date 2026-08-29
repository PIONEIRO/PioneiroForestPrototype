# Pioneiro Forest Prototype

Protótipo novo, criado do zero em **Godot 4.7.1**, para testar a direção visual do futuro RPG sem usar o projeto antigo PIONEIRO QUEST.

## O que existe na V1

- uma mata compacta top-down 3/4;
- árvores grandes, pinheiros, arbustos, pedras, troncos, flores e trilha de terra;
- profundidade por posição no chão: jogador e monstros passam na frente/atrás dos elementos;
- colisão concentrada na base/tronco das árvores;
- jogador com movimento em 8 direções;
- câmera suave;
- 2 slimes + 2 javalis;
- monstros com idle, caminhada, perseguição, dano e morte simples;
- ataque de teste para avaliar leitura visual;
- arte vetorial original SVG, sem dependência do PIONEIRO QUEST.

## Controles

- **WASD** ou **setas**: mover
- **Espaço**: ataque curto na direção atual

## Como testar no Windows

### 1. GitHub Desktop

1. Abra o GitHub Desktop.
2. Vá em **File → Clone repository...**.
3. Abra a aba **URL**.
4. Cole: `https://github.com/PIONEIRO/PioneiroForestPrototype`
5. Escolha uma pasta nova, por exemplo `C:\Users\SEU_USUARIO\Documents\Godot\PioneiroForestPrototype`.
6. Clique em **Clone**.
7. No topo do GitHub Desktop, clique em **Current branch**.
8. Selecione **`forest-visual-prototype-v1`**.
9. Clique em **Fetch origin** / **Pull origin** se aparecer.

> A branch `main` fica deliberadamente limpa enquanto o visual está em avaliação. Teste a branch `forest-visual-prototype-v1`.

### 2. Godot

1. Abra o **Godot 4.7.1**.
2. No Project Manager, clique em **Import**.
3. Selecione o arquivo `project.godot` dentro da pasta `PioneiroForestPrototype` clonada pelo GitHub Desktop.
4. Confirme **Import & Edit**.
5. Quando o editor abrir, aperte **F5**.
6. A cena deve iniciar diretamente na mata.

## O que observar no teste visual

- tamanho do personagem em relação às árvores;
- densidade da mata;
- sensação de câmera top-down 3/4;
- passagem do personagem na frente e atrás das copas;
- se a colisão dos troncos parece natural;
- leitura visual entre slime e javali;
- se esse nível de detalhe é o caminho certo antes de desenvolver o restante do jogo.

## Licenças

Consulte `ASSET_LICENSES.md`. Qualquer asset gratuito externo que entrar nas próximas versões terá origem e licença registradas antes do commit.
