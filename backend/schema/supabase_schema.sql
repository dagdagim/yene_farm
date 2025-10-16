-- Enable pgcrypto for UUID generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Users table
CREATE TABLE IF NOT EXISTS public.users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email text UNIQUE NOT NULL,
    password_hash text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    phone text,
    user_type text NOT NULL CHECK (user_type IN ('farmer', 'buyer', 'admin')),
    profile_image text,
    address jsonb,
    is_verified boolean DEFAULT false,
    is_active boolean DEFAULT true,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS users_email_idx ON public.users (email);
CREATE INDEX IF NOT EXISTS users_user_type_idx ON public.users (user_type);

-- Categories table
CREATE TABLE IF NOT EXISTS public.categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamptz DEFAULT now()
);

-- Products table
CREATE TABLE IF NOT EXISTS public.products (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    description text,
    price numeric(10,2) NOT NULL DEFAULT 0,
    images text[] DEFAULT '{}',
    category_id uuid REFERENCES categories(id),
    seller_id uuid REFERENCES users(id) ON DELETE CASCADE,
    quantity_available integer DEFAULT 0,
    unit text DEFAULT 'kg',
    is_available boolean DEFAULT true,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS products_created_at_idx ON public.products (created_at DESC);

-- Orders table
CREATE TABLE IF NOT EXISTS public.orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    items jsonb NOT NULL,
    total numeric(12,2) NOT NULL DEFAULT 0,
    shipping_address jsonb,
    payment_method text,
    payment_status text DEFAULT 'pending',
    order_status text NOT NULL DEFAULT 'pending' CHECK (order_status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS orders_buyer_id_idx ON public.orders (buyer_id);
CREATE INDEX IF NOT EXISTS orders_status_idx ON public.orders (order_status);

-- Chat messages table
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
    message text NOT NULL,
    message_type text DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
    is_read boolean DEFAULT false,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS chat_messages_sender_idx ON public.chat_messages (sender_id);
CREATE INDEX IF NOT EXISTS chat_messages_receiver_idx ON public.chat_messages (receiver_id);
CREATE INDEX IF NOT EXISTS chat_messages_order_idx ON public.chat_messages (order_id);

-- Notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title text NOT NULL,
    message text NOT NULL,
    type text NOT NULL CHECK (type IN ('order', 'message', 'system', 'promotion')),
    is_read boolean DEFAULT false,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON public.notifications (user_id);
CREATE INDEX IF NOT EXISTS notifications_type_idx ON public.notifications (type);

-- Reviews table
CREATE TABLE IF NOT EXISTS public.reviews (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
    rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment text,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS reviews_product_id_idx ON public.reviews (product_id);
CREATE INDEX IF NOT EXISTS reviews_reviewer_id_idx ON public.reviews (reviewer_id);

-- Seed sample categories
INSERT INTO public.categories (name, description)
VALUES
('Fruits', 'Fresh fruits from local farmers'),
('Vegetables', 'Organic vegetables'),
('Dairy', 'Milk and other dairy products')
ON CONFLICT DO NOTHING;

-- Seed sample products
INSERT INTO public.products (title, description, price, images, category_id)
SELECT
    'Avocado', 'Fresh Ethiopian avocado', 2.5, ARRAY['https://example.com/avocado.jpg'], id
FROM public.categories WHERE name='Fruits'
ON CONFLICT DO NOTHING;

INSERT INTO public.products (title, description, price, images, category_id)
SELECT
    'Tomato', 'Organic red tomatoes', 1.2, ARRAY['https://example.com/tomato.jpg'], id
FROM public.categories WHERE name='Vegetables'
ON CONFLICT DO NOTHING;
