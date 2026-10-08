INSERT INTO ingredients (name) VALUES
 ('flour'),('sugar'),('egg'),('butter'),('milk'),('rice'),('dal'),('onion'),('tomato'),('oil')
ON CONFLICT DO NOTHING;

INSERT INTO recipes (id,name) VALUES (1,'Pancakes'),(2,'Dal Rice'),(3,'Omelette')
ON CONFLICT DO NOTHING;
SELECT setval('recipes_id_seq', GREATEST((SELECT MAX(id) FROM recipes),1));

INSERT INTO recipe_items (recipe_id, ingredient_id, base_qty)
SELECT 1, id, v FROM ingredients, LATERAL (SELECT CASE name
  WHEN 'flour' THEN 240.0 WHEN 'milk' THEN 240.0 WHEN 'egg' THEN 100.0
  WHEN 'sugar' THEN 30.0 WHEN 'butter' THEN 30.0 END AS v) t
WHERE v IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO recipe_items (recipe_id, ingredient_id, base_qty)
SELECT 2, id, v FROM ingredients, LATERAL (SELECT CASE name
  WHEN 'rice' THEN 300.0 WHEN 'dal' THEN 200.0 WHEN 'onion' THEN 100.0
  WHEN 'tomato' THEN 100.0 WHEN 'oil' THEN 15.0 END AS v) t
WHERE v IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO recipe_items (recipe_id, ingredient_id, base_qty)
SELECT 3, id, v FROM ingredients, LATERAL (SELECT CASE name
  WHEN 'egg' THEN 150.0 WHEN 'onion' THEN 50.0 WHEN 'oil' THEN 15.0 END AS v) t
WHERE v IS NOT NULL ON CONFLICT DO NOTHING;

INSERT INTO pantry (user_name, ingredient_id, base_qty)
SELECT 'demo', id, v FROM ingredients, LATERAL (SELECT CASE name
  WHEN 'egg' THEN 300.0 WHEN 'onion' THEN 200.0 WHEN 'oil' THEN 500.0
  WHEN 'rice' THEN 1000.0 WHEN 'dal' THEN 500.0 END AS v) t
WHERE v IS NOT NULL ON CONFLICT DO NOTHING;
