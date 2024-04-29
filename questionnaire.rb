require "pstore" # https://github.com/ruby/pstore

class Survey
  STORE_NAME = "tendable.pstore"

  def initialize
    @store = PStore.new(STORE_NAME)
  end

  QUESTIONS = {
    "q1" => "Can you code in Ruby?",
    "q2" => "Can you code in JavaScript?",
    "q3" => "Can you code in Swift?",
    "q4" => "Can you code in Java?",
    "q5" => "Can you code in C#?"
  }.freeze

  def do_prompt
    answers = {}
    # Ask each question and get an answer from the user's input.
    QUESTIONS.each do |question_key, question|
      loop do
        print "#{question} "
        ans = gets.chomp.downcase
        if %w(yes no y n).include?(ans) && !ans.include?(' ')
          answers[question_key] = ans == 'yes' || ans == 'y'
          break
        else
          puts "Invalid input. Please enter 'Yes' or 'No' or 'Y' or 'N' without spaces."
        end
      end
    end
    persist_answers(answers)
    do_report(answers)
  end

  def do_report(answers)
    total_yes = answers.values.count(true)
    total_questions = QUESTIONS.size
    rating = (100 * total_yes) / total_questions
    puts "Rating for this run: #{rating}%"

    average_rating = calculate_average_rating
    puts "Average rating for all runs: #{average_rating}%"
  end

  private

  def calculate_average_rating
    total_yes = 0
    total_questions = 0
    @store.transaction(true) do
      @store[:answers]&.each do |answer|
        total_yes += answer.values.count(true)
        total_questions += QUESTIONS.size
      end
    end
    average_rating = 100 * total_yes.to_f / total_questions
    average_rating.round(2)
  end

  def persist_answers(answers)
    @store.transaction do
      @store[:answers] ||= []
      @store[:answers] << answers
    end
  end
end

survey = Survey.new
survey.do_prompt
