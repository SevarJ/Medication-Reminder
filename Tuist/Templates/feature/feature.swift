import Foundation
import ProjectDescription

let name: Template.Attribute = .required("name")

let today: String = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter.string(from: Date())
}()

let root = "Modules/Features/{{ name }}"

let template = Template(
    description: "Feature with an interface (route and module protocol), an Impl and a test target",
    attributes: [
        name,
        .optional("author", default: "Sevar Jafarli"),
        .optional("date", default: .string(today)),
    ],
    items: [
        .file(path: "\(root)/Interface/Sources/Route/{{ name }}Route.swift", templatePath: "Interface/Route.stencil"),
        .file(path: "\(root)/Interface/Sources/Module/{{ name }}Module.swift", templatePath: "Interface/Module.stencil"),
        .file(path: "\(root)/Impl/Sources/Module/{{ name }}ModuleImpl.swift", templatePath: "Impl/ModuleImpl.stencil"),
        .file(path: "\(root)/Impl/Sources/Module/{{ name }}ModuleConfigurator.swift", templatePath: "Impl/ModuleConfigurator.stencil"),
        .file(path: "\(root)/Impl/Sources/{{ name }}/{{ name }}View.swift", templatePath: "Impl/View.stencil"),
        .file(path: "\(root)/Impl/Sources/{{ name }}/{{ name }}ViewModel.swift", templatePath: "Impl/ViewModel.stencil"),
        .file(path: "\(root)/Impl/Resources/Localizable.xcstrings", templatePath: "Impl/Localizable.stencil"),
        .file(path: "\(root)/Tests/{{ name }}/{{ name }}ViewModelTests.swift", templatePath: "Tests/ViewModelTests.stencil"),
    ]
)
