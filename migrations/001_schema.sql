CREATE TABLE IF NOT EXISTS ingredients (
    id SERIAL PRIMARY KEY, name TEXT UNIQUE NOT NULL);

CREATE TABLE IF NOT EXISTS recipes (
    id SERIAL PRIMARY KEY, name TEXT NOT NULL);

CREATE TABLE IF NOT EXISTS recipe_items (
    recipe_id INT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_id INT NOT NULL REFERENCES ingredients(id),
    base_qty NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (recipe_id, ingredient_id));

CREATE TABLE IF NOT EXISTS pantry (
    user_name TEXT NOT NULL,
    ingredient_id INT NOT NULL REFERENCES ingredients(id),
    base_qty NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (user_name, ingredient_id));
