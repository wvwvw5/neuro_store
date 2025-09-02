--
-- PostgreSQL database dump
--

\restrict a89dfgmSX5ZrpOmeSGQSYCXd99IhbOLy6eISRAgg29ENlBGFOeDJBAqf5kseHfB

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    id bigint NOT NULL,
    table_name character varying(100) NOT NULL,
    record_id bigint,
    action character varying(20) NOT NULL,
    old_values jsonb,
    new_values jsonb,
    user_id bigint,
    "timestamp" timestamp with time zone DEFAULT now()
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_log_id_seq OWNER TO postgres;

--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint,
    plan_id bigint,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency character varying(3) DEFAULT 'RUB'::character varying,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: COLUMN orders.product_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.product_id IS 'ID продукта (NULL для пополнения баланса)';


--
-- Name: COLUMN orders.plan_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.orders.plan_id IS 'ID плана (NULL для пополнения баланса)';


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    user_id bigint NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency character varying(3) DEFAULT 'RUB'::character varying,
    payment_method character varying(50),
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    payment_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    transaction_id character varying(255)
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: COLUMN payments.transaction_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.payments.transaction_id IS 'ID транзакции в платежной системе';


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payments_id_seq OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plans (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(12,2) NOT NULL,
    duration_days integer NOT NULL,
    max_requests_per_month integer,
    features text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.plans OWNER TO postgres;

--
-- Name: plans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.plans_id_seq OWNER TO postgres;

--
-- Name: plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plans_id_seq OWNED BY public.plans.id;


--
-- Name: product_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_plans (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    plan_id bigint NOT NULL,
    is_available boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.product_plans OWNER TO postgres;

--
-- Name: product_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_plans_id_seq OWNER TO postgres;

--
-- Name: product_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_plans_id_seq OWNED BY public.product_plans.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(100),
    api_endpoint text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: revenue_analytics; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.revenue_analytics AS
 SELECT date_trunc('month'::text, o.created_at) AS month,
    p.name AS product_name,
    pl.name AS plan_name,
    count(o.id) AS orders_count,
    sum(o.amount) AS total_revenue,
    avg(o.amount) AS avg_order_value
   FROM ((public.orders o
     JOIN public.products p ON ((o.product_id = p.id)))
     JOIN public.plans pl ON ((o.plan_id = pl.id)))
  WHERE ((o.status)::text = 'completed'::text)
  GROUP BY (date_trunc('month'::text, o.created_at)), p.id, p.name, pl.id, pl.name
  ORDER BY (date_trunc('month'::text, o.created_at)) DESC, (sum(o.amount)) DESC;


ALTER TABLE public.revenue_analytics OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriptions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint NOT NULL,
    plan_id bigint NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    auto_renew boolean DEFAULT false,
    requests_used integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.subscriptions OWNER TO postgres;

--
-- Name: subscription_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.subscription_summary AS
 SELECT p.name AS product_name,
    pl.name AS plan_name,
    count(s.id) AS total_subscriptions,
    count(
        CASE
            WHEN ((s.status)::text = 'active'::text) THEN 1
            ELSE NULL::integer
        END) AS active_subscriptions,
    avg(pl.price) AS avg_price,
    sum(pl.price) AS total_revenue
   FROM (((public.products p
     JOIN public.product_plans pp ON ((p.id = pp.product_id)))
     JOIN public.plans pl ON ((pp.plan_id = pl.id)))
     LEFT JOIN public.subscriptions s ON (((p.id = s.product_id) AND (pl.id = s.plan_id))))
  WHERE ((p.is_active = true) AND (pl.is_active = true))
  GROUP BY p.id, p.name, pl.id, pl.name;


ALTER TABLE public.subscription_summary OWNER TO postgres;

--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subscriptions_id_seq OWNER TO postgres;

--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: usage_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usage_events (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    subscription_id bigint,
    product_id bigint NOT NULL,
    event_type character varying(100) NOT NULL,
    request_data jsonb,
    response_data jsonb,
    tokens_used integer,
    cost numeric(12,6),
    duration_ms integer,
    status character varying(50) DEFAULT 'success'::character varying,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.usage_events OWNER TO postgres;

--
-- Name: usage_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usage_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usage_events_id_seq OWNER TO postgres;

--
-- Name: usage_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usage_events_id_seq OWNED BY public.usage_events.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    phone character varying(20),
    balance numeric(12,2) DEFAULT 0.00,
    is_active boolean DEFAULT true,
    is_verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: user_activity; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_activity AS
 SELECT u.id,
    u.email,
    u.first_name,
    u.last_name,
    count(s.id) AS total_subscriptions,
    count(
        CASE
            WHEN ((s.status)::text = 'active'::text) THEN 1
            ELSE NULL::integer
        END) AS active_subscriptions,
    sum(o.amount) AS total_spent,
    count(ue.id) AS total_requests
   FROM (((public.users u
     LEFT JOIN public.subscriptions s ON ((u.id = s.user_id)))
     LEFT JOIN public.orders o ON ((u.id = o.user_id)))
     LEFT JOIN public.usage_events ue ON ((u.id = ue.user_id)))
  GROUP BY u.id, u.email, u.first_name, u.last_name;


ALTER TABLE public.user_activity OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_roles_id_seq OWNER TO postgres;

--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: plans id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plans ALTER COLUMN id SET DEFAULT nextval('public.plans_id_seq'::regclass);


--
-- Name: product_plans id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_plans ALTER COLUMN id SET DEFAULT nextval('public.product_plans_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: usage_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_events ALTER COLUMN id SET DEFAULT nextval('public.usage_events_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_log (id, table_name, record_id, action, old_values, new_values, user_id, "timestamp") FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, user_id, product_id, plan_id, status, amount, currency, notes, created_at, updated_at) FROM stdin;
35	37	1	1	completed	299.00	RUB	\N	2025-09-02 21:50:20.87087+00	2025-09-02 21:50:20.87087+00
36	37	2	5	completed	0.00	RUB	\N	2025-09-02 21:54:54.259302+00	2025-09-02 21:54:54.259302+00
38	37	\N	\N	completed	500.00	RUB	\N	2025-09-02 22:07:50.280548+00	2025-09-02 22:07:59.364978+00
39	37	\N	\N	completed	200.00	RUB	\N	2025-09-02 22:24:27.678828+00	2025-09-02 22:24:36.576299+00
40	37	\N	\N	completed	1000.00	RUB	\N	2025-09-02 22:32:32.460684+00	2025-09-02 22:32:42.847087+00
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, order_id, user_id, amount, currency, payment_method, status, payment_date, created_at, updated_at, transaction_id) FROM stdin;
1	35	37	299.00	RUB	balance	completed	2025-09-02 21:50:20.881291+00	2025-09-02 21:50:20.87087+00	2025-09-02 21:50:20.87087+00	\N
2	36	37	0.00	RUB	balance	completed	2025-09-02 21:54:54.274014+00	2025-09-02 21:54:54.259302+00	2025-09-02 21:54:54.259302+00	\N
3	38	37	500.00	RUB	card	completed	2025-09-02 22:07:50.28982+00	2025-09-02 22:07:50.280548+00	2025-09-02 22:07:59.364978+00	TXN_38_1756850870
4	39	37	200.00	RUB	card	completed	2025-09-02 22:24:27.686714+00	2025-09-02 22:24:27.678828+00	2025-09-02 22:24:36.576299+00	TXN_39_1756851867
5	40	37	1000.00	RUB	card	completed	2025-09-02 22:32:32.467245+00	2025-09-02 22:32:32.460684+00	2025-09-02 22:32:42.847087+00	TXN_40_1756852352
\.


--
-- Data for Name: plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plans (id, name, description, price, duration_days, max_requests_per_month, features, is_active, created_at, updated_at) FROM stdin;
1	Базовый	Для начинающих пользователей	299.00	30	100	Базовый доступ к API, поддержка по email	t	2025-09-02 21:18:12.892512+00	2025-09-02 21:18:12.892512+00
2	Стандарт	Для активных пользователей	599.00	30	500	Расширенный доступ, приоритетная поддержка, аналитика	t	2025-09-02 21:18:12.892512+00	2025-09-02 21:18:12.892512+00
3	Премиум	Для профессионалов	1299.00	30	2000	Максимальный доступ, персональный менеджер, API ключи	t	2025-09-02 21:18:12.892512+00	2025-09-02 21:18:12.892512+00
4	Годовой	Выгодная годовая подписка	9999.00	365	25000	Все возможности Премиум + скидка 23%	t	2025-09-02 21:18:12.892512+00	2025-09-02 21:18:12.892512+00
5	Пробный	Пробный доступ на 7 дней	0.00	7	10	Ограниченный функционал для тестирования	t	2025-09-02 21:18:12.892512+00	2025-09-02 21:18:12.892512+00
\.


--
-- Data for Name: product_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_plans (id, product_id, plan_id, is_available, created_at) FROM stdin;
1	1	1	t	2025-09-02 21:18:12.892938+00
2	1	2	t	2025-09-02 21:18:12.892938+00
3	1	3	t	2025-09-02 21:18:12.892938+00
4	1	4	t	2025-09-02 21:18:12.892938+00
5	1	5	t	2025-09-02 21:18:12.892938+00
6	2	1	t	2025-09-02 21:18:12.892938+00
7	2	2	t	2025-09-02 21:18:12.892938+00
8	2	3	t	2025-09-02 21:18:12.892938+00
9	2	4	t	2025-09-02 21:18:12.892938+00
10	2	5	t	2025-09-02 21:18:12.892938+00
11	3	1	t	2025-09-02 21:18:12.892938+00
12	3	2	t	2025-09-02 21:18:12.892938+00
13	3	3	t	2025-09-02 21:18:12.892938+00
14	3	4	t	2025-09-02 21:18:12.892938+00
15	3	5	t	2025-09-02 21:18:12.892938+00
16	4	1	t	2025-09-02 21:18:12.892938+00
17	4	2	t	2025-09-02 21:18:12.892938+00
18	4	3	t	2025-09-02 21:18:12.892938+00
19	4	4	t	2025-09-02 21:18:12.892938+00
20	4	5	t	2025-09-02 21:18:12.892938+00
21	5	1	t	2025-09-02 21:18:12.892938+00
22	5	2	t	2025-09-02 21:18:12.892938+00
23	5	3	t	2025-09-02 21:18:12.892938+00
24	5	4	t	2025-09-02 21:18:12.892938+00
25	5	5	t	2025-09-02 21:18:12.892938+00
26	6	1	t	2025-09-02 21:18:12.892938+00
27	6	2	t	2025-09-02 21:18:12.892938+00
28	6	3	t	2025-09-02 21:18:12.892938+00
29	6	4	t	2025-09-02 21:18:12.892938+00
30	6	5	t	2025-09-02 21:18:12.892938+00
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, description, category, api_endpoint, is_active, created_at, updated_at) FROM stdin;
1	ChatGPT	Мощная языковая модель для генерации текста, ответов на вопросы и творческих задач	Языковые модели	https://api.openai.com/v1/chat/completions	t	2025-09-02 21:18:12.89204+00	2025-09-02 21:18:12.89204+00
2	DALL-E	Создание уникальных изображений по текстовому описанию	Генерация изображений	https://api.openai.com/v1/images/generations	t	2025-09-02 21:18:12.89204+00	2025-09-02 21:18:12.89204+00
3	Midjourney	Создание художественных изображений высокого качества	Генерация изображений	https://api.midjourney.com/v1/generate	t	2025-09-02 21:18:12.89204+00	2025-09-02 21:18:12.89204+00
4	Claude	AI-ассистент от Anthropic для анализа текста и генерации контента	Языковые модели	https://api.anthropic.com/v1/messages	t	2025-09-02 21:18:12.89204+00	2025-09-02 21:18:12.89204+00
5	Stable Diffusion	Открытая модель для генерации изображений с высокой степенью контроля	Генерация изображений	https://api.stability.ai/v1/generation	t	2025-09-02 21:18:12.89204+00	2025-09-02 21:18:12.89204+00
6	Jasper	AI-помощник для создания маркетингового контента	Маркетинг	https://api.jasper.ai/v1/content	t	2025-09-02 21:18:12.89204+00	2025-09-02 21:18:12.89204+00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, description, is_active, created_at, updated_at) FROM stdin;
1	admin	Администратор системы	t	2025-09-02 21:18:12.891261+00	2025-09-02 21:18:12.891261+00
2	moderator	Модератор контента	t	2025-09-02 21:18:12.891261+00	2025-09-02 21:18:12.891261+00
3	user	Обычный пользователь	t	2025-09-02 21:18:12.891261+00	2025-09-02 21:18:12.891261+00
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscriptions (id, user_id, product_id, plan_id, status, start_date, end_date, auto_renew, requests_used, created_at, updated_at) FROM stdin;
34	37	1	1	active	2025-09-02 21:50:20.873166+00	2025-10-02 21:50:20.873166+00	t	0	2025-09-02 21:50:20.87087+00	2025-09-02 21:50:20.87087+00
35	37	2	5	active	2025-09-02 21:54:54.266834+00	2025-09-09 21:54:54.266834+00	t	0	2025-09-02 21:54:54.259302+00	2025-09-02 21:54:54.259302+00
\.


--
-- Data for Name: usage_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usage_events (id, user_id, subscription_id, product_id, event_type, request_data, response_data, tokens_used, cost, duration_ms, status, created_at) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (id, user_id, role_id, created_at) FROM stdin;
35	38	1	2025-09-02 21:44:21.571136+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, first_name, last_name, phone, balance, is_active, is_verified, created_at, updated_at) FROM stdin;
34	test@example.com	$2b$12$yVoN..G3COnK3r9OhK5kIuIOipM//fm4wEgzGYNtgSVh68HgzUHKe	Test	User	\N	0.00	t	f	2025-09-02 21:19:32.210713+00	2025-09-02 21:19:32.210713+00
36	test2@neurostore.com	$2b$12$jC7WoN0/6/iIBwoqtXXc9.P7KPBuv5UJDzL1rgPzWDvjjMN/gVq2C	Test2	User	\N	0.00	t	f	2025-09-02 21:37:53.109686+00	2025-09-02 21:37:53.109686+00
38	admin@neurostore.com	$2b$12$KLOLIzbKAe.28TlgyuBtt.0/uSJDutx9cL3u1g1R0HLALGFSo.3a.	Admin	User	\N	0.00	t	f	2025-09-02 21:44:14.968767+00	2025-09-02 21:44:14.968767+00
37	test@neurostore.com	$2b$12$chpugDsPhUGnhf3ky6JWuuw03VFqwNRaunbx4UbRH1KjqaZMCujlS	Test	User	\N	2401.00	t	f	2025-09-02 21:44:08.179672+00	2025-09-02 22:32:42.847087+00
\.


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, false);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 40, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 5, true);


--
-- Name: plans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plans_id_seq', 33, true);


--
-- Name: product_plans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_plans_id_seq', 33, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 33, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 33, true);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subscriptions_id_seq', 35, true);


--
-- Name: usage_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usage_events_id_seq', 1, false);


--
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_roles_id_seq', 35, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 38, true);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: plans plans_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_name_key UNIQUE (name);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: product_plans product_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_plans
    ADD CONSTRAINT product_plans_pkey PRIMARY KEY (id);


--
-- Name: product_plans product_plans_product_id_plan_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_plans
    ADD CONSTRAINT product_plans_product_id_plan_id_key UNIQUE (product_id, plan_id);


--
-- Name: products products_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_name_key UNIQUE (name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: usage_events usage_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_events
    ADD CONSTRAINT usage_events_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_user_id_role_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_id_key UNIQUE (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_log_table_record; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_log_table_record ON public.audit_log USING btree (table_name, record_id);


--
-- Name: idx_audit_log_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_log_timestamp ON public.audit_log USING btree ("timestamp");


--
-- Name: idx_orders_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_user_id ON public.orders USING btree (user_id);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_order_id ON public.payments USING btree (order_id);


--
-- Name: idx_payments_transaction_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_transaction_id ON public.payments USING btree (transaction_id);


--
-- Name: idx_subscriptions_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subscriptions_status ON public.subscriptions USING btree (status);


--
-- Name: idx_subscriptions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subscriptions_user_id ON public.subscriptions USING btree (user_id);


--
-- Name: idx_usage_events_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usage_events_user_id ON public.usage_events USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: orders update_orders_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: payments update_payments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: plans update_plans_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON public.plans FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: products update_products_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: subscriptions update_subscriptions_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: orders orders_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders orders_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: payments payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product_plans product_plans_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_plans
    ADD CONSTRAINT product_plans_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product_plans product_plans_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_plans
    ADD CONSTRAINT product_plans_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: subscriptions subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: subscriptions subscriptions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: usage_events usage_events_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_events
    ADD CONSTRAINT usage_events_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: usage_events usage_events_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_events
    ADD CONSTRAINT usage_events_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: usage_events usage_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_events
    ADD CONSTRAINT usage_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict a89dfgmSX5ZrpOmeSGQSYCXd99IhbOLy6eISRAgg29ENlBGFOeDJBAqf5kseHfB

