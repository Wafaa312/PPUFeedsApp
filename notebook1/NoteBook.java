/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.notebook1;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class NoteBook {
    private List<Note> notes;

    public NoteBook() {
        notes = new ArrayList<>();
    }

    public void storeNote(Note note) {
        notes.add(note);
    }
    
    public int numberOfNotes(){
        return notes.size();
    }
    
    
    public void showNote(int noteNo){
        if (noteNo< 0){
            System.out.println("this is invalid note number");
        }
        else if (noteNo>=0 && noteNo<numberOfNotes()){
            System.out.println( notes.get(noteNo));
        }
        else
            System.out.println( "this is invalid note number");
    }

    public String retrieveNoteById(int id) {
        if (id < 0 || id >= numberOfNotes()) {
            System.out.println("This is an invalid note number"); 
            return null;
        }
        else 
            return notes.toString();  
    }

    public void deleteNoteById(int id) {
        if (id >= 0 || id< notes.size()){
            notes.remove(id);
            System.out.println("note deleted successfully");}

        else
            System.out.println("this is an innvalid note id");
    }

    public void deleteNoteByTitle(String title) {
    if (title == null || title.isEmpty()) {
        System.out.println("This is an invalid note title");
    } else if (notes.contains(title)) {
        notes.remove(title);
        System.out.println("Note deleted successfully.");
    } else {
        System.out.println("Note not found.");
    }
}


public List<String> getNotesByDate(String date) {
    List<String> result = new ArrayList<>();

    for (Note note : notes) {
        if (note.getCreateDate().equals(date)) {
            result.add(note.toString());
        }
    }

    return result;
}



public List<String> getNotesFromWeekBefore() {
    List<String> result = new ArrayList<>();
    LocalDate today = LocalDate.now();
    LocalDate startOfLastWeek = today.minusWeeks(1).minusDays(6);
    LocalDate endOfLastWeek = today.minusWeeks(1);

    for (Note note : notes) {
        LocalDate noteDate = note.getCreateDate().toLocalDate(); 

        if (!noteDate.isBefore(startOfLastWeek) && !noteDate.isAfter(endOfLastWeek)) {
            result.add(note.toString());
        }
    }
    return result;
}




   public List<Note> getAllNotesOrderedByDate() {
    List<Note> sortedNotes = new ArrayList<>(notes);

    for (int i = 0; i < sortedNotes.size(); i++) {
        for (int j = i + 1; j < sortedNotes.size(); j++) {
            if (sortedNotes.get(i).getCreateDate().isAfter(sortedNotes.get(j).getCreateDate())) {
                Note temp = sortedNotes.get(i);
                sortedNotes.set(i, sortedNotes.get(j));
                sortedNotes.set(j, temp);
            }
        }
    }

    return sortedNotes;
}

 public List<Note> searchNoteByTitle(String title) {
    List<Note> matchingNotes = new ArrayList<>();

    for (int i = 0; i < notes.size(); i++) {
        if (notes.get(i).getTitle().toLowerCase().contains(title.toLowerCase())) {
            matchingNotes.add(notes.get(i));
        }
    }

    return matchingNotes;
}
}