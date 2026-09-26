import ProjectDescription

let tuist = Tuist(
    inspectOptions: .options(
        redundantDependencies: .redundantDependencies(ignoreTagsMatching: ["composition-root"])
    ),
    project: .tuist()
)
