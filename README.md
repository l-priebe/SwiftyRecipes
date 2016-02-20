# SwiftyRecipes
Swift API for fetching recipes online using Recipe Puppy <http://www.recipepuppy.com>.

## Usage
1. Include the files from the SwiftyRecipes folder in your project
2. Use the SRRecipeClient to fetch recipes online
3. Store the recipes as SRRecipe objects

## Examples
Below are some simple examples of using the API.

### Fetching recipes by keyword/query
```swift
let query = "italian"
var recipes: [SRRecipe]?
SRPuppyClient.sharedClient().fetchRecipesWithQuery(query, completionHandler: {
    result, _ in
    recipes = result
})
print(recipes)
```

### Fetching recipes by ingredients
```swift
let ingredients = ["tomato", "cucumber", "onion"]
var recipes: [SRRecipe]?
SRPuppyClient.sharedClient().fetchRecipesWithIngredients(ingredients, completionHandler: {
    result, _ in
    recipes = result
})
print(recipes)
```