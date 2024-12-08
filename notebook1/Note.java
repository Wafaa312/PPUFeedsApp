/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.notebook1;
import java.time.LocalDateTime;

public class Note {
    private int id;
    private LocalDateTime createDate;
    private String title;
    private String body;
    private Person author;

    public Note(int id, LocalDateTime createDate, String title, String body, Person author) {
        this.id = id;
        this.createDate = createDate;
        this.title = title;
        this.body = body;
        this.author = author;
    }

    public int getId() {
        return id;
    }

    public LocalDateTime getCreateDate() {
        return createDate;
    }

    public String getTitle() {
        return title;
    }

    public String getBody() {
        return body;
    }

    public Person getAuthor() {
        return author;
    }

    @Override
    public String toString() {
        return "Note{" +
                "id=" + id +
                ", createDate=" + createDate +
                ", title='" + title + '\'' +
                ", body='" + body + '\'' +
                ", author=" + author +
                '}';
    }
}

