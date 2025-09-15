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

// -----------------------------------------------------------------------------
// Namespace fix for AGP 8+.
//
// Starting with Android Gradle Plugin 8.0.0, every Android module must
// explicitly declare a `namespace`.  Some third‑party plugins used by this
// project (e.g. contacts_service) do not specify a namespace in their
// `build.gradle` files, which causes the build to fail with the error:
// "Namespace not specified. Please specify a namespace in the module's
// build.gradle".  To work around this, we iterate over each subproject
// after evaluation and assign a default namespace if none is provided.  This
// preserves compatibility with older plugins without needing to fork or
// modify their build scripts.  The assigned namespace uses the group ID
// (if available) or falls back to `com.example.<moduleName>`.
// When using the Kotlin DSL, the `afterEvaluate` API expects a lambda with no
// explicit `Project` parameter.  Referencing the project directly within the
// lambda avoids the type mismatch seen when declaring a parameter.  In
// addition, the `CommonExtension` type in AGP 8+ requires six type arguments
// instead of four.  Updating the generic signature and using the `this` scope
// resolves the "6 type arguments expected" compilation error.  The namespace
// assignment uses the group's value if available, otherwise defaults to
// `com.example.<moduleName>`.
subprojects {
    afterEvaluate {
        // Only configure Android modules
        val ext = this.extensions.findByName("android")
        if (ext is com.android.build.api.dsl.CommonExtension<*, *, *, *, *, *>) {
            // Assign a default namespace if one is not already defined.  Some
            // third‑party plugins neglect to declare a namespace, which is
            // required when building with AGP 8.  Derive a sensible default
            // based on the project's group or fall back to "com.example".
            if (ext.namespace.isNullOrEmpty()) {
                val base = this.group.toString().ifEmpty { "com.example" }
                ext.namespace = "$base.${this.name}"
            }
        }
    }
}
