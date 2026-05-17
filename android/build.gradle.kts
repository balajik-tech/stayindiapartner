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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    if (project.name != "app") {
        plugins.withType<com.android.build.gradle.BasePlugin> {
            configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(34)
                if (namespace.isNullOrEmpty()) {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val manifestText = manifestFile.readText()
                        val matchResult = Regex("""package=["']([^"']+)["']""").find(manifestText)
                        val packageName = matchResult?.groupValues?.get(1)
                        if (!packageName.isNullOrEmpty()) {
                            namespace = packageName
                        }
                    }
                    if (namespace.isNullOrEmpty()) {
                        namespace = project.group.toString().takeIf { it.isNotBlank() && it.contains(".") }
                            ?: "com.stayindia.${project.name.replace("-", "_").replace(" ", "_")}"
                    }
                }
            }
        }
    }
}


