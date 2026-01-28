# 🏨 Hotel Management System - SQL (EN)

A robust database implementation for managing hotel operations, built entirely in **Oracle PL/SQL**. This project focuses on back-end logic, data integrity, and automated business processes for hotels, rooms, clients, and employees.

## ✨ Features

-   **Relational Schema:** Comprehensive database structure including Hotels, Rooms, Clients, Reservations, Payments, Reviews, and Employees.
-   **Automated History Tracking:** A trigger-based system that automatically moves completed bookings to the `istoric_rezervari` table when their status changes to 'finalizata'.
-   **Business Rule Enforcement:** -   Automated salary range assignment based on hotel star ratings.
    -   Smart triggers to prevent assigning employee salaries outside the allowed range for their specific hotel.
-   **Modular Programming:** -   `modificari_tabele_hotel`: Package for dynamic schema updates and constraint management.
    -   `adaugare_date`: Package for systematic data seeding and initial setup.
-   **Reporting & Data Processing:** -   Cursors used for complex reporting of all client reservations.
    -   Procedures to bulk-update reservation statuses based on check-out dates.

## 🛠️ Technical Stack

-   **Language:** PL/SQL (Oracle)
-   **Key Concepts:** Triggers, Packages, Cursors, Exception Handling, Dynamic SQL (`EXECUTE IMMEDIATE`).

---

# 🏨 Sistem Gestiune Hoteliera - Backend (RO)

O implementare robusta a unei baze de date pentru gestionarea operatiunilor hoteliere, dezvoltata integral in **Oracle PL/SQL**. Acest proiect se concentreaza pe logica de back-end, integritatea datelor si automatizarea proceselor pentru hoteluri, camere, clienti si angajati.

## ✨ Functionalitati

-   **Schema Relationala:** Structura completa de baza de date care include tabele pentru Hoteluri, Camere, Clienti, Rezervari, Plati, Recenzii si Angajati.
-   **Monitorizarea Automata a Istoricului:** Sistem bazat pe triggere care muta automat rezervarile finalizate in tabela `istoric_rezervari`.
-   **Implementarea Regulilor de Business:**
    -   Alocarea automata a limitelor salariale in functie de numarul de stele al hotelului.
    -   Triggere inteligente care impiedica introducerea unor salarii in afara limitelor permise pentru hotelul respectiv.
-   **Programare Modulara:**
    -   `modificari_tabele_hotel`: Pachet pentru actualizarea dinamica a schemei si gestionarea restrictiilor de integritate.
    -   `adaugare_date`: Pachet pentru popularea sistematica a tabelelor cu date initiale.
-   **Raportare si Procesare Date:**
    -   Utilizarea cursorilor pentru raportarea detaliata a tuturor rezervarilor clientilor.
    -   Proceduri pentru actualizarea in masa a statusului rezervarilor in functie de data de check-out.

## 🛠️ Tehnologii Utilizate

-   **Limbaj:** PL/SQL (Oracle)
-   **Concepte Cheie:** Triggere, Pachete (Packages), Cursori, Gestionarea Exceptiilor, SQL Dinamic.

## 🚀 Utilizare / Setup

1.  Ruleaza scriptul intr-un mediu Oracle SQL (ex: SQL Developer sau Apex).
2.  Scriptul va sterge automat versiunile vechi ale tabelelor (daca exista) pentru o instalare curata.
3.  Tabelele, pachetele si datele de test vor fi generate automat, pe care le poti sterge ulterior.

---
Developed for database management and PL/SQL advanced programming study.
