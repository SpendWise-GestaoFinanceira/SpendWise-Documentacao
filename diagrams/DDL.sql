-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.Categorias (
  Id uuid NOT NULL,
  Nome character varying NOT NULL,
  Descricao character varying,
  Tipo integer NOT NULL,
  Prioridade integer NOT NULL,
  UsuarioId uuid NOT NULL,
  IsAtiva boolean NOT NULL DEFAULT true,
  LimiteValor numeric,
  LimiteMoeda character varying DEFAULT 'BRL'::character varying,
  CreatedAt timestamp with time zone NOT NULL,
  UpdatedAt timestamp with time zone,
  Cor character varying,
  CONSTRAINT Categorias_pkey PRIMARY KEY (Id),
  CONSTRAINT FK_Categorias_Usuarios_UsuarioId FOREIGN KEY (UsuarioId) REFERENCES public.Usuarios(Id)
);
CREATE TABLE public.FechamentosMensais (
  Id uuid NOT NULL DEFAULT gen_random_uuid(),
  UsuarioId uuid NOT NULL,
  AnoMes character varying NOT NULL,
  DataFechamento timestamp with time zone NOT NULL,
  Status integer NOT NULL,
  TotalReceitas numeric NOT NULL,
  TotalDespesas numeric NOT NULL,
  SaldoFinal numeric NOT NULL,
  Observacoes character varying,
  CreatedAt timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT FechamentosMensais_pkey PRIMARY KEY (Id),
  CONSTRAINT FK_FechamentosMensais_Usuarios_UsuarioId FOREIGN KEY (UsuarioId) REFERENCES public.Usuarios(Id)
);
CREATE TABLE public.Metas (
  Id uuid NOT NULL,
  Nome character varying NOT NULL,
  Descricao character varying NOT NULL,
  ValorObjetivo numeric NOT NULL,
  ValorObjetivo_Moeda text NOT NULL,
  Prazo date NOT NULL,
  ValorAtual numeric NOT NULL,
  ValorAtual_Moeda text NOT NULL,
  UsuarioId uuid NOT NULL,
  IsAtiva boolean NOT NULL DEFAULT true,
  DataAlcancada date,
  CreatedAt timestamp with time zone NOT NULL,
  UpdatedAt timestamp with time zone NOT NULL,
  CONSTRAINT Metas_pkey PRIMARY KEY (Id),
  CONSTRAINT FK_Metas_Usuarios_UsuarioId FOREIGN KEY (UsuarioId) REFERENCES public.Usuarios(Id)
);
CREATE TABLE public.Transacoes (
  Id uuid NOT NULL,
  Descricao character varying NOT NULL,
  Valor numeric NOT NULL,
  Moeda character varying NOT NULL DEFAULT 'BRL'::character varying,
  DataTransacao timestamp with time zone NOT NULL,
  Tipo integer NOT NULL,
  UsuarioId uuid NOT NULL,
  CategoriaId uuid NOT NULL,
  Observacoes character varying,
  CreatedAt timestamp with time zone NOT NULL,
  UpdatedAt timestamp with time zone,
  CONSTRAINT Transacoes_pkey PRIMARY KEY (Id),
  CONSTRAINT FK_Transacoes_Categorias_CategoriaId FOREIGN KEY (CategoriaId) REFERENCES public.Categorias(Id),
  CONSTRAINT FK_Transacoes_Usuarios_UsuarioId FOREIGN KEY (UsuarioId) REFERENCES public.Usuarios(Id)
);
CREATE TABLE public.Usuarios (
  Id uuid NOT NULL,
  Nome character varying NOT NULL,
  Email character varying NOT NULL,
  Senha character varying NOT NULL,
  RendaMensal numeric NOT NULL,
  IsAtivo boolean NOT NULL DEFAULT true,
  PasswordResetToken character varying,
  PasswordResetTokenExpiry timestamp with time zone,
  CreatedAt timestamp with time zone NOT NULL,
  UpdatedAt timestamp with time zone,
  CONSTRAINT Usuarios_pkey PRIMARY KEY (Id)
);
CREATE TABLE public.__EFMigrationsHistory (
  MigrationId character varying NOT NULL,
  ProductVersion character varying NOT NULL,
  CONSTRAINT __EFMigrationsHistory_pkey PRIMARY KEY (MigrationId)
);
CREATE TABLE public.orcamentos_mensais (
  id uuid NOT NULL,
  usuario_id uuid NOT NULL,
  ano_mes character varying NOT NULL CHECK (ano_mes::text ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'::text),
  Valor numeric NOT NULL CHECK ("Valor" >= 0::numeric),
  Moeda character varying NOT NULL DEFAULT 'BRL'::character varying,
  criado_em timestamp with time zone NOT NULL,
  atualizado_em timestamp with time zone,
  CONSTRAINT orcamentos_mensais_pkey PRIMARY KEY (id),
  CONSTRAINT FK_orcamentos_mensais_Usuarios_usuario_id FOREIGN KEY (usuario_id) REFERENCES public.Usuarios(Id)
);
