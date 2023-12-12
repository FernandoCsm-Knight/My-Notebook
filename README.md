# My-Notebook

### Desenvolvedor: Fernando Campos Silva Dal Maria

O aplicativo “My Notebook" é uma ferramenta multifuncional destinada a ajudar os usuários na organização e gerenciamento de suas notas, além de oferecer funcionalidades relacionadas a PDFs. Ele foi projetado para ser intuitivo e fácil de usar, com várias características destacadas:

- **Criação de Notas:** Os usuários podem criar notas rapidamente, adicionando títulos e conteúdos, facilitando a organização de pensamentos e informações.
- **Conversão de PDF para Texto para Fala (TTS):** Uma característica notável é a capacidade de converter PDFs em texto para fala (TTS), o que é especialmente útil para a leitura de documentos e livros em formato PDF.
- **Gerenciamento de Notas:** Oferece facilidades para editar e excluir notas, permitindo aos usuários manter suas informações atualizadas e organizadas.
- **Compartilhamento de PDFs:** Os usuários podem compartilhar PDFs com outros, além de buscar e gerenciar PDFs compartilhados, promovendo a colaboração e o compartilhamento de informações.
- **Configurações e Preferências:** Permite a personalização de várias configurações do aplicativo para se adequarem às preferências do usuário.


## Público Alvo

O My Notebook, direcionado a usuários a partir de 10 anos de idade, alinha-se estrategicamente com as necessidades e habilidades em evolução da terceira infância, uma fase marcada pelo desenvolvimento cognitivo acentuado, maior independência e aprimoramento das habilidades de leitura e escrita. Esta ferramenta de gerenciamento de notas e documentos digitais atende à crescente demanda por organização e autonomia no aprendizado, característica dessa faixa etária. Ao oferecer uma plataforma que combina funcionalidades educacionais com tecnologia intuitiva, o My Notebook não apenas se torna uma ferramenta útil para o estudo e a organização diária, mas também ajuda a cultivar habilidades de gerenciamento de tempo e recursos digitais que são essenciais no mundo moderno.

## Arquitetura de Pastas

A arquitetura de pastas do projeto consiste em 2 subdivisões. Inicialmente observe que dentro da pasta raiz `lib` exitem diversas pastas com nomes representado diferentes funcionalidades do aplicativo. Para cada pasta de funcionalidade podem existir três subpastas, uma denominada `screens` que apresenta as telas utilizadas para que o aplicativo execute determinada funcionalidade, outra denominada `services` que apresenta os serviços que são utilizados pelo aplicativo para executar determinada funcionalidade e finalmente uma pasta denominada `models` que apresenta a descrição dos objetos utilizados pelo sistema para armazenar e manejar as funcionalidades e os serviços.

Veja a seguir uma descrição mais detalhada de cada pasta:

**lib:** Esta é a pasta raiz que contém todo o código Dart do aplicativo "My Notebook".
**authentication:**

- **screens:** Contém interfaces do usuário para autenticação, como login_screen.dart, que provavelmente é a tela de login.
- **service:** Inclui lógicas de negócios e comunicação com APIs para autenticação, como em auth_service.dart.

**common:** Armazena componentes e utilitários usados em várias partes do aplicativo. Inclui elementos de interface como application_bottom_app_bar.dart e application_drawer.dart.

- **camera:** Módulo para funcionalidades relacionadas à câmera.
- - **models:** Define estruturas de dados para a câmera.
- - **services:** Inclui serviços como camera_service.dart para operações relacionadas à câmera.
- **storage:** Gerencia o armazenamento de dados.
- - **paths:** Define caminhos para o armazenamento de arquivos, como storage_paths.dart.
- - **services:** Serviços de armazenamento, incluindo file_service.dart e image_service.dart. Arquivos como database.dart e encryption_helper.dart sugerem funcionalidades de banco de dados e criptografia.

**home:** Módulo para a tela inicial ou funcionalidades principais do aplicativo. Inclui componentes, interfaces e serviços específicos para a tela inicial.

**info:** Módulo para páginas de informações do aplicativo.
- **screens:** Contém telas como about_screen.dart, help_screen.dart e privacy_policy_screen.dart.

**notes:** Módulo para funcionalidades relacionadas a anotações. Inclui componentes de interface, modelos de dados, telas e serviços para criar, gerenciar e visualizar anotações.

**profile:** Módulo para a gestão de perfis de usuário. Contém telas e serviços para visualização e edição de perfis de usuário.

**search:** Módulo para funcionalidades de busca. Inclui componentes, modelos de dados, telas e serviços para a busca, possivelmente de documentos PDF.

**settings:** Módulo para configurações do aplicativo. Contém modelos, telas e serviços para gerenciar configurações do usuário.

**upload:** Módulo para upload de arquivos, como PDFs. Inclui modelos, telas e serviços relacionados ao processo de upload.

**main.dart:** O ponto de entrada principal do aplicativo.

