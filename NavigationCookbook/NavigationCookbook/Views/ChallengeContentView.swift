/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The content view for the WWDC22 challenge.
*/

import SwiftUI

struct ChallengeContentView: View {
    @Binding var showExperiencePicker: Bool
    @EnvironmentObject private var navigationModel: NavigationModel
    @State private var searchText: String = ""
    var dataModel = DataModel.shared

    var body: some View {
        NavigationSplitView {
            List(selection: $navigationModel.selectedRecipe) {
                ForEach(Category.allCases) { category in
                    Section(category.localizedName) {
                        ForEach(dataModel.recipes(in: category, nameFilter: searchText)) { recipe in
                            NavigationLink(recipe.name, value: recipe)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search recipe")
            .listStyle(.sidebar)
            .navigationTitle("Cookbook")
            .toolbar {
                ExperienceButton(isActive: $showExperiencePicker)
            }
        } detail: {
            NavigationStack(path: $navigationModel.currentRecipeStack) {
                RecipeDetail(recipe: navigationModel.selectedRecipe, relatedLink:  { related in
                    Button {
                        navigationModel.visitRelated(recipe: related)
                    } label: {
                        RecipeTile(recipe: related)
                    }
                    .buttonStyle(.plain)
                }, path: navigationModel.currentRecipeStack)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetail(recipe: recipe, relatedLink:  { related in
                    Button {
                        navigationModel.visitRelated(recipe: related)
                    } label: {
                        RecipeTile(recipe: related)
                    }
                    .buttonStyle(.plain)
                }, path: navigationModel.currentRecipeStack)
            }
        }
    }
}

struct ChallengeContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeContentView(showExperiencePicker: .constant(false))
            .environmentObject(NavigationModel(
                columnVisibility: .all,
                selectedCategory: .dessert,
                recipePath: [.mock]))
            .previewInterfaceOrientation(.landscapeRight)
    }
}
