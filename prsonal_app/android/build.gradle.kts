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

// Some plugins (e.g. flutter_plugin_android_lifecycle via file_picker) require
// their dependents to compile against SDK 36+. But file_picker hardcodes
// compileSdk 34 in its own build.gradle, so we must override *after* each
// plugin subproject is evaluated. The :app module is skipped here — it is
// pre-evaluated by evaluationDependsOn(":app") above (which makes registering
// an afterEvaluate hook on it fail) and already pins compileSdk 36 directly.
subprojects {
    if (!state.executed) {
        afterEvaluate {
            val androidExtension = extensions.findByName("android")
            if (androidExtension is com.android.build.gradle.BaseExtension) {
                androidExtension.compileSdkVersion(36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
