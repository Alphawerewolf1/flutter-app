plugins {
    id("com.android.application") apply false
    id("com.google.gms.google-services") apply false
}

allprojects {
    repositories {
        google()       // ✅ Required for Firebase artifacts
        mavenCentral() // ✅ Backup repository
    }
}

// ✅ Move build output to another drive (e.g. D:\FlutterBuilds)
val customBuildDir = File("D:/FlutterBuilds/${rootProject.name}").absoluteFile

rootProject.layout.buildDirectory.set(customBuildDir)

subprojects {
    layout.buildDirectory.set(customBuildDir.resolve(name))
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
