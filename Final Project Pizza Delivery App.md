# Final Project: Pizza Delivery App System - Mobile & Web Administration
---
## 1. Project Name
**Pizza Delivery App System**
---
## 2. Purpose 
The main objective of the Pizza Delivery App System project is to develop a comprehensive, end-to-end digital solution for a pizza delivery business. This system serves as the final project for the Mobile Application Programming course, demonstrating mastery in cross-platform development, robust authentication implementation, cloud data synchronization, and modern state management principles (BLoC Pattern).
The project is composed of two primary applications that interact seamlessly using Firebase Cloud Firestore as a centralized data source: a customer-facing Mobile Application (built with Flutter) and an administrative Web Portal (also built with Flutter for Web).
---
## 3. Team Members (Integrantes)
| Role | Name | Contribution |
| :--- | :--- | :--- |
| **Project Lead / Mobile Developer** | [Aarón Obed González Martín] | Core architecture, responsive UI for Mobile App, Firebase integration. |
| **Web Developer / Database Admin** | [Aarón Obed González Martín] | Web Portal CRUD logic, Supabase/Firestore image handling, authentication flow. |
---
## 4. Key Features (Funciones Clave)
The PizzaFlow System is divided into two modules, each with specific core functionalities
### 📱 A. Customer Mobile Application (bobjk123/pizza_app_8sc_gmao)
This application is built with **Flutter** (Dart) and utilizes **Firebase Authentication** and **Cloud Firestore** for a modern, responsive user experience.
| Feature Category | Key Functions |
| :--- | :--- |
| **User Authentication** | Secure user sign-up and sign-in via Firebase Auth. |
| **Pizza Catalog** | Responsive grid display of available pizzas, fetching data dynamically from Cloud Firestore. Layout adapts to phone, tablet, and desktop screens (`SliverGridDelegate`). |
| **Pizza Details** | Dedicated screen to view full details of a selected pizza, including a description, ingredients, and macro information. |
| **Image Handling** | Advanced image loading logic that attempts to load images from a network resource and implements a graceful **fallback** to a local asset if the network resource fails or is unavailable. |
| **Data Access Layer** | Defensive data access using **flutter_bloc** and dedicated repositories (`pizza_repository`, `user_repository`) to manage state and handle Firestore permissions/errors effectively. |
### 💻 B. Administrative Web Portal (bobjk123/pizza_app_admin_gmao)
This web application is also built with **Flutter for Web** (Dart) and is used to manage the menu data that is displayed in the mobile application.
| Feature Category | Key Functions |
| :--- | :--- |
| **Admin Authentication** | Separate secure login flow for administrative users using Firebase Auth. |
| **Menu Management (CRUD)** | Comprehensive interface to perform **C**reate, **R**ead, **U**pdate, and **D**elete operations on the pizza menu. Changes are instantly reflected in the Cloud Firestore database for real-time synchronization with the mobile app. |
| **Image Upload** | Functionality to upload and associate images with new or existing pizza items. The implementation supports integration with **Supabase Storage** for production environments (or a local file simulation for development/demo purposes). |
| **Data Synchronization** | Ensures consistency between the admin view and customer view by managing all pizza metadata through Cloud Firestore. |
