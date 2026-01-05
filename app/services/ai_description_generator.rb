class AiDescriptionGenerator
  include HTTParty
  base_uri 'https://api.groq.com/openai/v1'

  def initialize
    @api_key = ENV['GROQ_API_KEY']
  end

  def generate_description(event_title:, category_name:, capacity: nil)
    return { error: "API key not configured" } unless @api_key.present?
    return { error: "Event title is required" } unless event_title.present?

    prompt = build_prompt(event_title, category_name, capacity)

    begin
      response = self.class.post(
        '/chat/completions',
        headers: {
          'Authorization' => "Bearer #{@api_key}",
          'Content-Type' => 'application/json'
        },
        body: {
          model: 'llama-3.3-70b-versatile', # Fast and free model (updated Dec 2024)
          messages: [
            {
              role: 'system',
              content: 'You are a professional event description writer. Create engaging, detailed, and professional event descriptions that attract attendees. Keep descriptions between 100-200 words.'
            },
            {
              role: 'user',
              content: prompt
            }
          ],
          temperature: 0.7,
          max_tokens: 300
        }.to_json,
        timeout: 15
      )

      if response.success?
        description = response.dig('choices', 0, 'message', 'content')
        { description: description.strip }
      else
        Rails.logger.error("Groq API Error: #{response.code} - #{response.body}")
        { error: "Failed to generate description. Please try again." }
      end
    rescue StandardError => e
      Rails.logger.error("AI Description Generation Error: #{e.message}")
      { error: "An error occurred. Please try again." }
    end
  end

  private

  def build_prompt(title, category, capacity)
    prompt = "Write a compelling event description for an event titled '#{title}'"
    prompt += " in the #{category} category" if category.present?
    prompt += " with a capacity of #{capacity} attendees" if capacity.present?
    prompt += ". Make it engaging and informative. Focus on what attendees will experience and why they should attend."
    prompt
  end
end
