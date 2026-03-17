workspace {
    model {
        user = person "Language Learner" "A user going over this week's words and playing practice games on the SongLingo app."
        
        // External APIs
        spotify = softwareSystem "Spotify API" "Provides weekly playlist links, short clips for song games, and song metadata." {
            tags "External"
        }
        genius = softwareSystem "Genius API" "Provides accurate song lyrics for NLP analysis and gameplay." {
            tags "External"
        }

        songlingo = softwareSystem "SongLingo System" "Allows users to learn languages through music." {
            mobileApp = container "iOS App" "Provides the user interface and audio playback." "Swift" {
                tags "Mobile App"
            }
            database = container "Database" "Stores users, songs, vocabulary, and progress." "PostgreSQL" {
                tags "Database"
            }
            
            // The API Server with internal components
            apiServer = container "API Server" "Handles game logic, user progress, and routes data." "Python / Django REST Framework" {
                tags "Backend"
                coreModels = component "Core Models" "Defines the database schema (UserProfile, Song, Vocabulary)." "Django Models" {
                    tags "Django Module"
                }
                apiViews = component "API Views" "Handles incoming requests and game logic." "Django Views" {
                    tags "Django Module"
                }
                serializers = component "Serializers" "Translates database objects into JSON." "DRF Serializers" {
                    tags "Django Module"
                }
                spacyAlgorithm = component "Difficulty Algorithm" "Analyzes song lyrics to assign reading difficulty." "SpaCy / Python" {
                    tags "Algorithm"
                }
            }
        }

        // The Relationships (Arrows)
        user -> songlingo "Learns languages using"
        user -> mobileApp "Interacts with"
        
        mobileApp -> apiServer "Makes API requests to" "JSON/HTTPS"
        
        // Internal container relationships
        apiServer -> database "Reads from and writes to" "SQL/TCP"
        apiServer -> spotify "Fetches audio clip URLs, playlists, song metadata" "JSON/HTTPS"
        apiServer -> genius "Fetches song lyrics from" "JSON/HTTPS"
        
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

        // --- THE MODERN STYLE SECTION ---
        styles {
            element "Software System" {
                background #4F46E5
                color #ffffff
                shape RoundedBox
            }
            element "Person" {
                background #EC4899
                color #ffffff
                shape Person
            }
            element "External" {
                background #0D9488
                color #ffffff
            }
            element "Mobile App" {
                background #F97316
                color #ffffff
                shape MobileDevicePortrait
            }
            element "Database" {
                background #10B981
                color #ffffff
                shape Cylinder
            }
            element "Backend" {
                background #3B82F6
                color #ffffff
            }
            element "Django Module" {
                background #93C5FD
                color #000000
            }
            element "Algorithm" {
                background #8B5CF6
                color #ffffff
                shape Hexagon
            }
        }
    }
}