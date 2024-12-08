/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.notebook1;
import java.time.LocalDateTime;

public class Notebook1 {
    public static void main(String[] args) {
        NoteBook notebook = new NoteBook();
        Person author = new Person("Wafaa Abuawwad");

        notebook.storeNote(new Note(1, LocalDateTime.now(), "lecture", "lecture at 09:45 AM", author));
        notebook.storeNote(new Note(2, LocalDateTime.now().minusDays(2), "Exam", "OOP exam details", author));
        notebook.storeNote(new Note(3, LocalDateTime.now().minusWeeks(1), "HW", "submit computer networks hw", author));

        System.out.println("Retrieve Note by ID (1):");
        System.out.println(notebook.retrieveNoteById(2));

        System.out.println("\nAll Notes Ordered by Date:");
        notebook.getAllNotesOrderedByDate().forEach(System.out::println);

        System.out.println("\nSearch Notes by Title (Exam):");
        notebook.searchNoteByTitle("Exam").forEach(System.out::println);

        System.out.println("\nNotes from the Last Week:");
        notebook.getNotesFromWeekBefore().forEach(System.out::println);

       }
}
