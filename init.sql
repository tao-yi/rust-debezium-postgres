CREATE TABLE IF NOT EXISTS public.cashflow (
    "id" bigserial NOT NULL,
    "amount" int NOT NULL,
    "description" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT now(),
    CONSTRAINT "cashflow_pkey" PRIMARY KEY (id)
);