# 🎓 Sistema de Chamada e Gestão Escolar

Sistema web desenvolvido em **Ruby on Rails** para gerenciamento acadêmico escolar, permitindo o controle de frequência, lançamento de notas, cálculo de médias bimestrais e anuais, além do acompanhamento gerencial por parte da direção.

O projeto foi estruturado com base em **perfis de acesso (roles)**, garantindo que cada tipo de usuário tenha permissões específicas e acesso apenas às funcionalidades pertinentes ao seu papel.

---

## 👥 Perfis de Acesso

### 👨‍🏫 Professor
- Realiza a **chamada** (controle de presença/faltas) dos alunos.
- Lança **pontos e notas** por aluno, organizados por bimestre.
- Calcula automaticamente:
  - Soma de pontos por bimestre;
  - **Média bimestral**;
  - **Média geral anual** (a partir dos 4 bimestres).

### 🧑‍🎓 Aluno
- Consulta suas **faltas**.
- Visualiza suas **notas** por bimestre.
- Acompanha suas **médias bimestrais e anual**.

### 🧑‍💼 Diretor
- Acesso **total** ao sistema.
- Realiza o **controle gerencial** de professores, alunos e funcionários da escola.
- Gerencia cadastros, permissões e acompanha o desempenho geral da instituição.
- Controla o mural de avisos da escola.

---

## ⚙️ Funcionalidades

- 🔐 Autenticação e autorização por perfil (Professor / Aluno / Diretor);
- 📋 Registro de chamada e controle de faltas;
- 📝 Lançamento de pontos e notas por bimestre;
- 📊 Cálculo automático de médias bimestrais e média geral anual;
- 🗂️ Gestão de usuários (professores, alunos e funcionários);
- 📈 Painel gerencial para a direção;
- 🎯 Interface para consulta de desempenho por parte dos alunos.

---

## 🛠️ Tecnologias Utilizadas

- **Ruby** (versão 4.0.9)
- **Ruby on Rails** (versão 8.1.4)
- **PostgreSQL** (banco de dados)
- **HTML / CSS / JavaScript**
- **Bootstrap** (ou outra framework de estilização)
- **Devise** (autenticação) *(se aplicável)*
- **RSpec / Minitest** (testes) *(se aplicável)*

> ⚠️ Ajuste as versões e dependências de acordo com o seu projeto.

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- Ruby instalado
- Rails instalado
- PostgreSQL (ou banco configurado no `database.yml`)
- Bundler

### Passo a passo

```bash
# Clone o repositório
git clone https://github.com/thallesonofre/estudante.git

# Acesse o diretório
cd seu-repositorio

# Instale as dependências
bundle install

# Configure o banco de dados
rails db:create
rails db:migrate
rails db:seed

# Inicie o servidor
rails server
```

Acesse em: `http://localhost:3000`

---

## 📁 Estrutura de Pastas (resumo)

```
app/
├── controllers/
├── models/
├── views/
├── services/       # Regras de negócio (cálculo de médias, etc.)
config/
db/
spec/               # Testes
```

---

## 🧮 Regras de Cálculo

- **Média Bimestral** = Soma dos pontos/notas do bimestre ÷ Quantidade de avaliações;
- **Média Anual** = (Média 1º Bim + Média 2º Bim + Média 3º Bim + Média 4º Bim) ÷ 4.

---

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir **issues** ou enviar **pull requests**.

1. Faça um fork do projeto;
2. Crie uma branch: `git checkout -b minha-feature`;
3. Commit suas alterações: `git commit -m "feat: minha feature"`;
4. Push: `git push origin minha-feature`;
5. Abra um Pull Request.

---

## 📄 Licença

Este projeto está sob a licença **MIT**. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## ✉️ Contato

Desenvolvido por **Thalles Onfre**  
📧 thalles.onofre@gmail.com  
🔗 [Site](https://gatewayro.com)