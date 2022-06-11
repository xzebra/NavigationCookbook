/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A detail view the app uses to display the metadata for a given recipe,
 as well as its related recipes.
*/

import SwiftUI

struct RecipeDetail<Link: View>: View {
    var recipe: Recipe?
    var relatedLink: (Recipe) -> Link
    var path: [Recipe]?
    
    @EnvironmentObject private var navigationModel: NavigationModel

    var body: some View {
        // Workaround for a known issue where `NavigationSplitView` and
        // `NavigationStack` fail to update when their contents are conditional.
        // For more information, see the iOS 16 Release Notes and
        // macOS 13 Release Notes. (91311311)"
        ZStack {
            if let recipe = recipe {
                RecipeDetailContent(recipe: recipe, relatedLink: relatedLink)
            } else {
                Text("Choose a recipe")
                    .navigationTitle("")
            }
        }
    }
}

// MARK: conditional rendering of breadcrumb when exploring recipes related stack view
// If there is no path, there is no need to show the icon. navigationTitle should not
// show the dropdown icon when there are no buttons inside of it. But we have to
// implement it ourselves.
struct DropdownBreadcrumb: ViewModifier {
    var titleText: String
    
    @EnvironmentObject private var navigationModel: NavigationModel
    
    func body(content: Content) -> some View {
        let path = navigationModel.currentRecipeStack
        
        if path.isEmpty {
            content.navigationTitle(titleText)
        } else {
            content
                .navigationTitle(titleText) {
                    let current = navigationModel.selectedRecipe
                    if let current = current {
                        Button(current.name) {
                            navigationModel.currentRecipeStack.removeAll()
                        }
                    }
                    ForEach(path) { recipeInPath in
                        Button(recipeInPath.name) {
                            navigationModel.visitRelated(recipe: recipeInPath)
                        }
                    }
                }
        }
    }
}

extension View {
    func breadcrumbed(withTitle title: String) -> some View {
        modifier(DropdownBreadcrumb(titleText: title))
    }
}


private struct RecipeDetailContent<Link: View>: View {
    var recipe: Recipe
    var dataModel = DataModel.shared
    var relatedLink: (Recipe) -> Link
    
    @EnvironmentObject private var navigationModel: NavigationModel
    
    var body: some View {
        ScrollView {
            ViewThatFits(in: .horizontal) {
                wideDetails
                narrowDetails
            }
            .padding()
        }
        .breadcrumbed(withTitle: recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    var wideDetails: some View {
        VStack(alignment: .leading) {
            title
            HStack(alignment: .top) {
                image
                ingredients
                Spacer()
            }
            relatedRecipes
        }
    }

    var narrowDetails: some View {
        let alignment: HorizontalAlignment
        #if os(macOS)
        alignment = .leading
        #else
        alignment = .center
        #endif
        return VStack(alignment: alignment) {
            title
            image
            ingredients
            relatedRecipes
        }
    }
    
    var title: some View {
        #if os(macOS)
        Text(recipe.name)
            .font(.largeTitle)
        #else
        EmptyView()
        #endif
    }

    var image: some View {
        RecipePhoto(recipe: recipe)
            .frame(width: 300, height: 300)
    }

    @ViewBuilder
    var ingredients: some View {
        let padding = EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0)
        VStack(alignment: .leading) {
            Text("Ingredients")
                .font(.headline)
                .padding(padding)
            VStack(alignment: .leading) {
                ForEach(recipe.ingredients) { ingredient in
                    Text(ingredient.description)
                }
            }
        }
        .frame(minWidth: 300, alignment: .leading)
    }

    @ViewBuilder
    var relatedRecipes: some View {
        let padding = EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0)
        if !recipe.related.isEmpty {
            VStack(alignment: .leading) {
                Text("Related Recipes")
                    .font(.headline)
                    .padding(padding)
                LazyVGrid(columns: columns, alignment: .leading) {
                    let relatedRecipes = dataModel.recipes(relatedTo: recipe)
                    ForEach(relatedRecipes) { relatedRecipe in
                        relatedLink(relatedRecipe)
                    }
                }
            }
        }
    }

    var columns: [GridItem] {
        [ GridItem(.adaptive(minimum: 120, maximum: 120)) ]
    }
}

struct RecipeDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecipeDetail(recipe: nil, relatedLink: link)
            RecipeDetail(recipe: .mock, relatedLink: link)
        }
    }
    
    static func link(recipe: Recipe) -> some View {
        EmptyView()
    }
}
