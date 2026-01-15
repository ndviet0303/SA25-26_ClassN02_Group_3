@startuml
header Nozie Streaming Platform - Full Business Scope
title Detailed Use Case Diagram (25+ UCs) - All Micro;s

left to right direction
skinparam packageStyle rectangle
skinparam shadowing false
skinparam roundcorner 5

'--- Actors Configuration ---
actor "Customer" as User
actor "Content Manager" as Staff
actor "System Admin" as Admin

'--- External Systems ---
rectangle "External Systems" as External {
    actor "OAuth Provider\n(Google/FB)" as OAuth <<;>>
    actor "Stripe Engine" as Stripe <<>>
    actor "CDN" as CDN <<Cloud>>
    actor "TMDB API" as TMDB <<;>>
    actor "FCM/Email Server" as NotifyGate <<;>>
}

rectangle "Nozie Micro;s System" {

    '-- ; 1: Identity & Security --
    package "Identity ;" {
        (Register) as UC1
        (Login via Credentials) as UC2
        (Social Auth Login) as UC2_1
        (Two-Factor Auth) as UC2_2
        (Logout & Revoke Token) as UC3
        (Change Password) as UC4
        (Manage User Sessions) as UC5
        (Assign Roles/Permissions) as UC6
        (View System Audit Logs) as UC7
        (Enrich User Profile) as UC8
        
        UC2_1 -- OAuth
    }

    '-- ; 2: Movie & Streaming --
    package "Movie ;" {
        (Browse Movie Catalog) as UC9
        (Advanced Search) as UC10
        (Watch Movie) as UC11
        (Add to Watchlist) as UC12
        (Rate & Review Movie) as UC13
        (Get AI Recommendations) as UC14
        (Upload & Manage Content) as UC15
        (Sync Data with TMDB) as UC16
        
        UC11 -- CDN
        UC16 -- TMDB
    }

    '-- ; 3: Customer & History --
    package "Customer ;" {
        (View Subscription Plans) as UC17
        (Check Membership Status) as UC18
        (Track Viewing History) as UC19
        (Manage Membership Rules) as UC20
    }

    '-- ; 4: Payment & Billing --
    package "Payment ;" {
        (Checkout & Pay) as UC21
        (Receive Payment Webhook) as UC22
        (View Billing History) as UC23
        (Request Refund) as UC24
        
        UC21 -- Stripe
        UC22 -- Stripe
    }

    '-- ; 5: Notification --
    package "Notification ;" {
        (Send Transactional Alert) as UC25
        (Send Marketing Push) as UC26
        (Send Security Alert) as UC27
        
        UC25 -- NotifyGate
        UC26 -- NotifyGate
        UC27 -- NotifyGate
    }
}

'--- Mapping Customer ---
User --> UC1
User --> UC2
User --> UC2_1
User --> UC2_2
User --> UC3
User --> UC4
User --> UC5
User --> UC8
User --> UC9
User --> UC10
User --> UC11
User --> UC12
User --> UC13
User --> UC14
User --> UC17
User --> UC18
User --> UC19
User --> UC21
User --> UC23
User --> UC24

'--- Mapping Content Manager ---
Staff --> UC15
Staff --> UC16
Staff --> UC9

'--- Mapping System Admin ---
Admin --> UC6
Admin --> UC7
Admin --> UC20
Admin --> UC15

'--- Logical Includes/Extends ---
UC11 .> UC18 : <<include>> : Check subscription
UC21 .> UC25 : <<extend>> : Notify on success
UC27 .> UC2_2 : <<extend>> : Failed 2FA alert

@enduml