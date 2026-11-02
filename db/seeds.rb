# frozen_string_literal: true

puts "🌱 Iniciando população do banco de dados do Sistema Estudante..."

AccessRequest.destroy_all
Assessment.destroy_all
Attendance.destroy_all
Enrollment.destroy_all
Subject.destroy_all
Classroom.destroy_all
Announcement.destroy_all
User.destroy_all

# 1. Diretor
director = User.create!(
  name: "Dr. Thalles Onofre",
  email: "diretor@estudante.edu.br",
  password: "password123",
  role: :director,
  registration_number: "DIR-2026001",
  phone: "(11) 99800-1001",
  department: "Diretoria Executiva & Pedagógica",
  job_title: "Diretor Geral"
)

# 2. Funcionários da Escola (Staff)
staff1 = User.create!(
  name: "Mariana Vasconcelos",
  email: "secretaria@estudante.edu.br",
  password: "password123",
  role: :staff,
  registration_number: "FUNC-2026010",
  phone: "(11) 99800-2001",
  department: "Secretaria Acadêmica",
  job_title: "Secretária Escolar Chefe"
)

staff2 = User.create!(
  name: "Roberto Albuquerque",
  email: "coordenacao@estudante.edu.br",
  password: "password123",
  role: :staff,
  registration_number: "FUNC-2026011",
  phone: "(11) 99800-2002",
  department: "Coordenação Pedagógica",
  job_title: "Coordenador Disciplinar"
)

# 3. Professores
prof_carlos = User.create!(
  name: "Prof. Carlos Eduardo Mendes",
  email: "professor@estudante.edu.br",
  password: "password123",
  role: :teacher,
  registration_number: "PROF-2026101",
  phone: "(11) 99710-3001",
  department: "Ciências Exatas & Matemática",
  job_title: "Professor Titular"
)

prof_helena = User.create!(
  name: "Profa. Helena Costa Azevedo",
  email: "helena.azevedo@estudante.edu.br",
  password: "password123",
  role: :teacher,
  registration_number: "PROF-2026102",
  phone: "(11) 99710-3002",
  department: "Linguagens e Literatura",
  job_title: "Professora Titular"
)

prof_ricardo = User.create!(
  name: "Prof. Ricardo Nogueira",
  email: "ricardo.nogueira@estudante.edu.br",
  password: "password123",
  role: :teacher,
  registration_number: "PROF-2026103",
  phone: "(11) 99710-3003",
  department: "Ciências Humanas & História",
  job_title: "Professor Adjunto"
)

# 4. Turmas
turma_3a = Classroom.create!(
  name: "3º Ano A",
  academic_year: 2026,
  shift: "Matutino",
  room_number: "Sala 301",
  grade_level: "Ensino Médio"
)

turma_2b = Classroom.create!(
  name: "2º Ano B",
  academic_year: 2026,
  shift: "Matutino",
  room_number: "Sala 204",
  grade_level: "Ensino Médio"
)

turma_9a = Classroom.create!(
  name: "9º Ano A",
  academic_year: 2026,
  shift: "Vespertino",
  room_number: "Sala 105",
  grade_level: "Ensino Fundamental II"
)

# 5. Disciplinas
sub_mat_3a = Subject.create!(
  name: "Matemática e Suas Tecnologias",
  code: "MAT-3A",
  workload_hours: 120,
  classroom: turma_3a,
  teacher: prof_carlos
)

sub_fis_3a = Subject.create!(
  name: "Física Aplicada",
  code: "FIS-3A",
  workload_hours: 80,
  classroom: turma_3a,
  teacher: prof_carlos
)

sub_por_3a = Subject.create!(
  name: "Língua Portuguesa e Redação",
  code: "POR-3A",
  workload_hours: 120,
  classroom: turma_3a,
  teacher: prof_helena
)

sub_his_3a = Subject.create!(
  name: "História Geral e do Brasil",
  code: "HIS-3A",
  workload_hours: 80,
  classroom: turma_3a,
  teacher: prof_ricardo
)

sub_mat_2b = Subject.create!(
  name: "Matemática II",
  code: "MAT-2B",
  workload_hours: 100,
  classroom: turma_2b,
  teacher: prof_carlos
)

# 6. Alunos da Turma 3º Ano A
student_profiles_3a = [
  { name: "Lucas Gabriel Ferreira", email: "aluno@estudante.edu.br", reg: "MAT-20260001", profile: :excellent },
  { name: "Beatriz Almeida Santos", email: "beatriz.santos@estudante.edu.br", reg: "MAT-20260002", profile: :excellent },
  { name: "Gabriel Henrique Rocha", email: "gabriel.rocha@estudante.edu.br", reg: "MAT-20260003", profile: :good },
  { name: "Camila Ribeiro Lima", email: "camila.lima@estudante.edu.br", reg: "MAT-20260004", profile: :good },
  { name: "Matheus Oliveira Souza", email: "matheus.souza@estudante.edu.br", reg: "MAT-20260005", profile: :attention },
  { name: "Júlia Martins Cardoso", email: "julia.cardoso@estudante.edu.br", reg: "MAT-20260006", profile: :good },
  { name: "Rafael Pereira Gomes", email: "rafael.gomes@estudante.edu.br", reg: "MAT-20260007", profile: :attention }
]

students_3a = student_profiles_3a.map do |sp|
  student = User.create!(
    name: sp[:name],
    email: sp[:email],
    password: "password123",
    role: :student,
    registration_number: sp[:reg],
    phone: "(11) 99500-#{rand(1000..9999)}"
  )
  Enrollment.create!(student: student, classroom: turma_3a, enrolled_on: Date.new(2026, 2, 2))
  [ student, sp[:profile] ]
end

# Alunos da Turma 2º Ano B
[
  { name: "Fernanda Castro Dias", email: "fernanda.dias@estudante.edu.br", reg: "MAT-20260008" },
  { name: "Pedro Augusto Barros", email: "pedro.barros@estudante.edu.br", reg: "MAT-20260009" },
  { name: "Larissa Monteiro Cunha", email: "larissa.cunha@estudante.edu.br", reg: "MAT-20260010" }
].each do |sp|
  st = User.create!(
    name: sp[:name],
    email: sp[:email],
    password: "password123",
    role: :student,
    registration_number: sp[:reg]
  )
  Enrollment.create!(student: st, classroom: turma_2b, enrolled_on: Date.new(2026, 2, 2))

  [ 1, 2, 3, 4 ].each do |bim|
    Assessment.create!(student: st, subject: sub_mat_2b, bimester: bim, title: "Prova Bimestral", category: "Prova Bimestral", score: 7.8, evaluated_on: Date.new(2026, bim * 2, 15))
    Assessment.create!(student: st, subject: sub_mat_2b, bimester: bim, title: "Trabalho Prático", category: "Trabalho Prático", score: 8.4, evaluated_on: Date.new(2026, bim * 2, 22))
  end
end

# 7. Lançamento de Notas e Chamadas nos 4 Bimestres para o 3º Ano A
subjects_3a = [ sub_mat_3a, sub_fis_3a, sub_por_3a, sub_his_3a ]

lesson_dates = [
  { date: Date.new(2026, 3, 10), bim: 1, topic: "Introdução e Fundamentos do 1º Bimestre" },
  { date: Date.new(2026, 3, 24), bim: 1, topic: "Resolução de Exercícios e Aplicações Práticas" },
  { date: Date.new(2026, 4, 14), bim: 1, topic: "Revisão Geral para Avaliação do 1º Bimestre" },
  { date: Date.new(2026, 5, 12), bim: 2, topic: "Aprofundamento Teórico do 2º Bimestre" },
  { date: Date.new(2026, 6, 9),  bim: 2, topic: "Seminário Temático e Estudo Dirigido" },
  { date: Date.new(2026, 6, 23), bim: 2, topic: "Fechamento de Conteúdo do 1º Semestre" },
  { date: Date.new(2026, 8, 11), bim: 3, topic: "Tópicos Avançados do 3º Bimestre" },
  { date: Date.new(2026, 9, 8),  bim: 3, topic: "Simulado Preparatório ENEM / Vestibular" },
  { date: Date.new(2026, 10, 13), bim: 4, topic: "Projeto Integrador do 4º Bimestre" },
  { date: Date.new(2026, 10, 27), bim: 4, topic: "Revisão Anual Consolidada" }
]

students_3a.each_with_index do |(student, profile), idx|
  subjects_3a.each_with_index do |sub, s_idx|
    [ 1, 2, 3, 4 ].each do |bim|
      base_scores = case profile
      when :excellent
        [ 9.0 + ((bim + s_idx) % 2) * 0.5, 8.5 + (idx % 2) * 0.5, 9.5 ]
      when :good
        [ 7.0 + ((bim + s_idx) % 2) * 0.5, 7.5 + (idx % 2) * 0.5, 8.0 ]
      else
        [ 4.5 + (bim % 2) * 0.5, 5.0 + (s_idx % 2) * 0.5, 5.5 ]
      end

      Assessment.create!(
        student: student,
        subject: sub,
        bimester: bim,
        title: "Prova Bimestral",
        category: "Prova Bimestral",
        score: base_scores[0].clamp(0, 10),
        evaluated_on: Date.new(2026, bim * 2, 10)
      )

      Assessment.create!(
        student: student,
        subject: sub,
        bimester: bim,
        title: "Trabalho Prático",
        category: "Trabalho Prático",
        score: base_scores[1].clamp(0, 10),
        evaluated_on: Date.new(2026, bim * 2, 18)
      )

      Assessment.create!(
        student: student,
        subject: sub,
        bimester: bim,
        title: "Simulado",
        category: "Simulado",
        score: base_scores[2].clamp(0, 10),
        evaluated_on: Date.new(2026, bim * 2, 25)
      )
    end

    # Frequência / Chamadas
    lesson_dates.each_with_index do |ld, l_idx|
      status = if profile == :attention && (l_idx % 3).zero?
        :absent
      elsif profile == :good && l_idx == 4 && s_idx.zero?
        :absent
      elsif idx == 1 && l_idx == 2
        :justified
      else
        :present
      end

      Attendance.create!(
        student: student,
        subject: sub,
        attended_on: ld[:date],
        bimester: ld[:bim],
        status: status,
        lesson_topic: ld[:topic],
        justification: status == :justified ? "Atestado médico apresentado à secretaria" : nil
      )
    end
  end
end

# 8. Mural de Avisos da Escola
Announcement.create!(
  title: "Calendário Oficial de Avaliações do 4º Bimestre e Fechamento Anual",
  content: "Comunicamos a todos os professores e alunos que o lançamento final de notas e chamadas do 4º Bimestre estará aberto no sistema até o dia 28/11/2026. O sistema realiza automaticamente o cálculo da Média Bimestral e da Média Geral Anual a partir dos 4 bimestres.",
  priority: :urgent,
  audience: :everyone,
  pinned: true,
  author: director,
  published_at: 2.days.ago
)

Announcement.create!(
  title: "Conselho de Classe e Reunião Pedagógica Docente",
  content: "Convocamos o corpo docente para a reunião de acompanhamento pedagógico na sexta-feira às 14h00 na Sala da Diretoria. Analisaremos os indicadores do Radar Pedagógico.",
  priority: :important,
  audience: :teachers_only,
  pinned: false,
  author: director,
  published_at: 4.days.ago
)

Announcement.create!(
  title: "Simulado Geral e Mostra de Ciências 2026",
  content: "Parabenizamos todos os alunos do Ensino Médio e Fundamental pelo excelente engajamento na Mostra Científica e nos simulados bimestrais deste ano letivo!",
  priority: :normal,
  audience: :students_only,
  pinned: false,
  author: director,
  published_at: 6.days.ago
)

# 9. Solicitações de Acesso para Teste (Pendentes de aprovação do Admin/Diretor)
AccessRequest.create!(
  institution_name: "Colégio Santa Clara",
  institution_type: "Colégio Privado (Fundamental / Médio)",
  contact_name: "Dra. Patrícia Mendonça",
  email: "patricia@colegiosantaclara.com.br",
  phone: "(11) 99123-4567",
  requested_role: :director,
  status: :pending,
  message: "Gostaria de testar o painel gerencial e o cálculo de médias para nossos 620 alunos."
)

AccessRequest.create!(
  institution_name: "Instituto Técnico Evolução",
  institution_type: "Escola Técnica / Profissionalizante",
  contact_name: "Prof. Marcos Vinícius",
  email: "marcos@itevolucao.edu.br",
  phone: "(21) 98877-6655",
  requested_role: :teacher,
  status: :pending,
  message: "Quero avaliar o diário de chamada e lançamento de notas em lote."
)

puts "✅ Seeds concluídas com sucesso!"
puts "   Diretor:   diretor@estudante.edu.br   | Senha: password123"
puts "   Professor: professor@estudante.edu.br | Senha: password123"
puts "   Aluno:     aluno@estudante.edu.br     | Senha: password123"
