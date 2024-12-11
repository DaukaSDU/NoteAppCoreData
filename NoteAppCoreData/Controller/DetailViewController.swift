//
//  DetailViewController.swift
//  NoteAppCoreData
//
//  Created by Daulet Omar on 12.12.2024.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTV: UITextView!

    var selectedNote: Note?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the text fields with the selected note's information, if available
        if let note = selectedNote {
            titleTF.text = note.title
            descTV.text = note.desc
        }
    }

    @IBAction func saveAction(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        // Create or update note
        if selectedNote == nil {
            // Create a new note
            guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return }
            let newNote = Note(entity: entity, insertInto: context)
            newNote.id = NSNumber(value: noteList.count) // Ensure correct ID handling
            newNote.title = titleTF.text ?? ""
            newNote.desc = descTV.text
            newNote.createdAt = Date()
            newNote.updatedAt = Date()

            // Save the context and append to the note list
            do {
                try context.save()
                noteList.append(newNote)
                navigationController?.popViewController(animated: true)
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        } else {
            // Update existing note
            selectedNote?.title = titleTF.text ?? ""
            selectedNote?.desc = descTV.text
            selectedNote?.updatedAt = Date()

            // Save the updated note to the context
            do {
                try context.save()
                navigationController?.popViewController(animated: true)
            } catch {
                print("Error updating note: \(error.localizedDescription)")
            }
        }
    }
}
