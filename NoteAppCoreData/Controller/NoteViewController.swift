//
//  NoteViewController.swift
//  NoteAppCoreData
//
//  Created by Daulet Omar on 12.12.2024.
//


import UIKit
import CoreData

var noteList = [Note]()

class NoteViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var firstLoad = true
    var searchController: UISearchController!
    var filteredNotes = [Note]()
    
    // Get non-deleted notes
    func nonDeletedNotes() -> [Note] {
        return noteList.filter { $0.deletedDate == nil }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up the search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Load notes from Core Data only once on first load
        if firstLoad {
            firstLoad = false
            loadNotesFromCoreData()
        }
    }
    
    // Load notes from Core Data
    private func loadNotesFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Note>(entityName: "Note")

        do {
            let results = try context.fetch(request)
            noteList = results
        } catch {
            print("Failed to fetch notes: \(error.localizedDescription)")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteCellID", for: indexPath) as! NoteCell
        let thisNote = isFiltering() ? filteredNotes[indexPath.row] : nonDeletedNotes()[indexPath.row]
        
        noteCell.titleLabel.text = thisNote.title
        noteCell.descLabel.text = thisNote.desc
        if let updatedAt = thisNote.updatedAt {
            noteCell.timeLabel.text = "\(formatTime(updatedAt))"
        } else if let createdAt = thisNote.createdAt {
            noteCell.timeLabel.text = "\(formatTime(createdAt))"
        }
        
        return noteCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredNotes.count : nonDeletedNotes().count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote", let indexPath = tableView.indexPathForSelectedRow {
            let noteDetail = segue.destination as? DetailViewController
            let selectedNote = isFiltering() ? filteredNotes[indexPath.row] : nonDeletedNotes()[indexPath.row]
            noteDetail?.selectedNote = selectedNote
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // Search results update
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }

    // Filter notes based on search text
    func filterContentForSearchText(_ searchText: String) {
        filteredNotes = nonDeletedNotes().filter { note in
            note.title.lowercased().contains(searchText.lowercased()) ||
            note.desc.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    // Format time to string
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // Check if we are filtering results
    func isFiltering() -> Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    // Handle swipe-to-delete action
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToDelete: Note
            if isFiltering() {
                noteToDelete = filteredNotes[indexPath.row]
                filteredNotes.remove(at: indexPath.row)
            } else {
                noteToDelete = nonDeletedNotes()[indexPath.row]
                noteList.removeAll { $0 == noteToDelete }
            }
            
            deleteNoteFromCoreData(noteToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Delete note from Core Data
    private func deleteNoteFromCoreData(_ note: Note) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(note)
        
        do {
            try context.save()
        } catch {
            print("Error deleting note: \(error.localizedDescription)")
        }
    }
}
