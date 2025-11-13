

import Foundation

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let ingredients: [String]
    let description: String?
    let image: String?
    let dietaryTags: [String]
    var category: String?
    var mealType: String?  

    private enum CodingKeys: String, CodingKey {
        case name, ingredients, description, image, dietaryTags, category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        dietaryTags = try container.decodeIfPresent([String].self, forKey: .dietaryTags) ?? []
        category = try container.decodeIfPresent(String.self, forKey: .category)

        if let ingredientArray = try? container.decode([String].self, forKey: .ingredients) {
            ingredients = ingredientArray
        } else if let ingredientString = try? container.decode(String.self, forKey: .ingredients) {
            ingredients = ingredientString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        } else {
            ingredients = []
        }
    }
}
