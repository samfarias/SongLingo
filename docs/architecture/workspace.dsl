workspace {
    model {
        user = person "Language Learner" "A user going over this week's words and playing practice games on the SongLingo app."
        
        // External APIs
        spotify = softwareSystem "Spotify API" "Provides 30-second audio previews and song metadata."

        songlingo = softwareSystem "SongLingo System" "Allows users to learn languages through music." {
            mobileApp = container "iOS App" "Provides the user interface and audio playback." "Swift" "Mobile App"
            database = container "Database" "Stores users, songs, vocabulary, and progress." "PostgreSQL" "Database"
            
            // The API Server with internal components
            apiServer = container "API Server" "Handles game logic, user progress, and routes data." "Python / Django REST Framework" {
                coreModels = component "Core Models" "Defines the database schema (UserProfile, Song, Vocabulary)." "Django Models"
                apiViews = component "API Views" "Handles incoming requests and game logic." "Django Views"
                serializers = component "Serializers" "Translates database objects into JSON." "DRF Serializers"
                spacyAlgorithm = component "Difficulty Algorithm" "Analyzes song lyrics to assign reading difficulty." "SpaCy / Python"
            }
        }

        // The Relationships (Arrows)
        user -> songlingo "Learns languages using"
        user -> mobileApp "Interacts with"
        
        mobileApp -> apiServer "Makes API requests to" "JSON/HTTPS"
        
        // Internal container relationships
        apiServer -> database "Reads from and writes to" "SQL/TCP"
        apiServer -> spotify "Fetches audio clip URLs from" "JSON/HTTPS"
        
        // Django inner works
        apiViews -> coreModels "Queries data from"
        apiViews -> serializers "Uses to format data"
        apiViews -> spacyAlgorithm "Passes lyrics to calculate level"
        coreModels -> database "Reads and Writes"
    }

    views {
        // C1: Context Diagram (Zoomed out)
        systemContext songlingo "SystemContext" {
            include *
            autoLayout lr
        }

        // C2: Container Diagram (Mid-level)
        container songlingo "Containers" {
            include *
            autoLayout lr
        }
    
        // C3: Component Diagram (Zoomed in on Django)
        component apiServer "Components" {
            include *
            autoLayout lr
        }

        theme default
    }
}