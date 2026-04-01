import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/program.dart';

class DummyDataService {
  static List<Recipe> getRecipes() {
    return const [
      Recipe(
        id: 'r1',
        title: 'Avocado Artisan Toast',
        imageUrl: 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?auto=format&fit=crop&q=80&w=800',
        prepTime: '15 min',
        difficulty: 'Easy',
        likes: 124,
      ),
      Recipe(
        id: 'r2',
        title: 'Emerald Green Smoothie Bowl',
        imageUrl: 'https://images.unsplash.com/photo-1494597564530-871f2b93ac55?auto=format&fit=crop&q=80&w=800',
        prepTime: '10 min',
        difficulty: 'Easy',
        likes: 342,
      ),
      Recipe(
        id: 'r3',
        title: 'Roasted Asparagus with Lemon',
        imageUrl: 'https://images.unsplash.com/photo-1518569656558-1fdceb089c8a?auto=format&fit=crop&q=80&w=800',
        prepTime: '25 min',
        difficulty: 'Medium',
        likes: 89,
      ),
      Recipe(
        id: 'r4',
        title: 'Zucchini Noodles Pesto',
        imageUrl: 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?auto=format&fit=crop&q=80&w=800',
        prepTime: '20 min',
        difficulty: 'Medium',
        likes: 210,
      ),
      Recipe(
        id: 'r5',
        title: 'Matcha Pancakes',
        imageUrl: 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?auto=format&fit=crop&q=80&w=800',
        prepTime: '30 min',
        difficulty: 'Hard',
        likes: 450,
      ),
    ];
  }

  static List<Ingredient> getFridgeIngredients() {
    return const [
      Ingredient(
        id: 'i1',
        name: 'Avocado',
        quantity: 3,
        unit: 'pcs',
        category: 'Produce',
        imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i2',
        name: 'Spinach',
        quantity: 200,
        unit: 'g',
        category: 'Produce',
        imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i3',
        name: 'Almond Milk',
        quantity: 1.5,
        unit: 'L',
        category: 'Dairy',
        imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i4',
        name: 'Eggs',
        quantity: 8,
        unit: 'pcs',
        category: 'Dairy',
        imageUrl: 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i5',
        name: 'Cherry Tomatoes',
        quantity: 250,
        unit: 'g',
        category: 'Produce',
        imageUrl: 'https://images.unsplash.com/photo-1564834724105-918b73d1b9e0?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i6',
        name: 'Chicken Breast',
        quantity: 500,
        unit: 'g',
        category: 'Meat',
        imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i7',
        name: 'Broccoli',
        quantity: 1,
        unit: 'head',
        category: 'Produce',
        imageUrl: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i8',
        name: 'Cheddar Cheese',
        quantity: 150,
        unit: 'g',
        category: 'Dairy',
        imageUrl: 'https://images.unsplash.com/photo-1618164436241-4473940d1f5c?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i9',
        name: 'Lemons',
        quantity: 4,
        unit: 'pcs',
        category: 'Produce',
        imageUrl: 'https://images.unsplash.com/photo-1590502593747-422e118331fb?auto=format&fit=crop&q=80&w=200',
      ),
      Ingredient(
        id: 'i10',
        name: 'Basil',
        quantity: 1,
        unit: 'bunch',
        category: 'Herbs',
        imageUrl: 'https://images.unsplash.com/photo-1615486171448-4afffb8cc28d?auto=format&fit=crop&q=80&w=200',
      ),
    ];
  }

  static List<Program> getPrograms() {
    return const [
      Program(
        id: 'p1',
        title: '7-Day Detox',
        subtitle: 'Cleanse your body naturally',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=500',
      ),
      Program(
        id: 'p2',
        title: 'Keto Kickstart',
        subtitle: 'High fat, low carb meals',
        imageUrl: 'https://images.unsplash.com/photo-1606859191214-25806e8e24c3?auto=format&fit=crop&q=80&w=500',
      ),
      Program(
        id: 'p3',
        title: 'Plant Power',
        subtitle: '100% Vegan recipes',
        imageUrl: 'https://images.unsplash.com/photo-1498837167922-41c53bbf0e20?auto=format&fit=crop&q=80&w=500',
      ),
    ];
  }
}
