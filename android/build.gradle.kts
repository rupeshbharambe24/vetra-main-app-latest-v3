import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Workaround: some third-party libs (e.g., isar_flutter_libs 3.1.0+1) miss
// the namespace declaration required by newer AGP. Force-set it here to keep
// Gradle happy without editing pub cache sources.
subprojects {
    val configureAction = {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.configure<LibraryExtension> {
                compileSdk = 36
                defaultConfig {
                    targetSdk = 36
                }
                if (project.name == "isar_flutter_libs") {
                    namespace = "dev.isar.isar_flutter_libs"
                }
            }
        }
    }

    if (state.executed) {
        configureAction()
    } else {
        afterEvaluate {
            configureAction()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
