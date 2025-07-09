//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController {
    
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var answerButton0: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    
    private var questions = [TriviaQuestion]()
    private var currQuestionIndex = 0
    private var numCorrectQuestions = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        questionContainerView.layer.cornerRadius = 8.0
        
        fetchAndDisplayQuestions()
    }
    
    private func fetchAndDisplayQuestions() {
        TriviaQuestionService.fetchTriviaQuestions { [weak self] (fetchedQuestions, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching trivia questions: \(error.localizedDescription)")
                self.showErrorAlert(message: "Failed to load questions. Please check your connection and try again.")
                return
            }
            
            guard let questions = fetchedQuestions, !questions.isEmpty else {
                print("No questions were returned.")
                self.showErrorAlert(message: "Could not find any questions. Please try again later.")
                return
            }
            
            self.questions = questions
            self.currQuestionIndex = 0
            self.numCorrectQuestions = 0
            self.updateQuestion(withQuestionIndex: 0)
        }
    }
    
    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        guard questionIndex < questions.count else { return }
        
        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        
        let question = questions[questionIndex]
        questionLabel.text = question.question
        categoryLabel.text = question.category
        
        let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
        
        let allButtons = [answerButton0, answerButton1, answerButton2, answerButton3]
        allButtons.forEach { $0?.isHidden = true } // Hide all buttons initially.
        
        for (index, button) in allButtons.enumerated() {
            if index < answers.count {
                button?.setTitle(answers[index], for: .normal)
                button?.isHidden = false
            }
        }
    }
    
    private func updateToNextQuestion(answer: String) {
        if isCorrectAnswer(answer) {
            numCorrectQuestions += 1
        }
        
        currQuestionIndex += 1
        
        if currQuestionIndex < questions.count {
            updateQuestion(withQuestionIndex: currQuestionIndex)
        } else {
            showFinalScore()
        }
    }
    
    private func isCorrectAnswer(_ answer: String) -> Bool {
        return answer == questions[currQuestionIndex].correctAnswer
    }
    
    private func showFinalScore() {
        let alertController = UIAlertController(title: "Game Over!", message: "Final score: \(numCorrectQuestions)/\(questions.count)",preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
            self.fetchAndDisplayQuestions()
        }
        
        alertController.addAction(resetAction)
        present(alertController, animated: true, completion: nil)
    }

    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                                UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func didTapAnswerButton(_ sender: UIButton) {
        if let answerText = sender.titleLabel?.text {
            updateToNextQuestion(answer: answerText)
        }
    }
}
