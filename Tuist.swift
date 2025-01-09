import ProjectDescription

let tuist = Tuist(
    fullHandle: "tuist/FileSystem",
    project: .tuist(
        generationOptions: .options(
            optionalAuthentication: true
        )
    )
)
