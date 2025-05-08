allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// The clean task will delete the build directory of this project (android/build)
tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
