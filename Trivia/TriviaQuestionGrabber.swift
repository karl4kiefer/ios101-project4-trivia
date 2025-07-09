import Foundation

// Defines the structure of the overall API response from Open Trivia DB
struct TriviaResponse: Decodable {
    let response_code: Int
    let results: [TriviaQuestionDTO]
}

// Data Transfer Object that matches the JSON structure for a single question
struct TriviaQuestionDTO: Decodable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

class TriviaQuestionService {
    
    static func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?, Error?) -> Void) {
        
        let timestamp = Int(Date().timeIntervalSince1970)

        let urlString = "https://opentdb.com/api.php?amount=5&type=multiple&_=\(timestamp)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "TriviaQuestionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "TriviaQuestionService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
                let questions = triviaResponse.results.map { dto in
                    return TriviaQuestion(
                        category: dto.category.decoded,
                        question: dto.question.decoded,
                        correctAnswer: dto.correct_answer.decoded,
                        incorrectAnswers: dto.incorrect_answers.map { $0.decoded }
                    )
                }
                DispatchQueue.main.async {
                    completion(questions, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}

extension String {
    var decoded: String {
        let attributedString = try? NSAttributedString(
            data: data(using: .utf8)!,
            options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        return attributedString?.string ?? self
    }
}
