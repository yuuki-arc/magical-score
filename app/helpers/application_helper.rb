module ApplicationHelper
  
  DIFFICULTIES_TEXT_COLOR = {'EASY' => 'text-info', 'NORMAL' => 'text-success', 'HARD' => 'text-warning', 'EXTREME' => 'text-danger'}

  def get_difficulty_color(difficulty)

    DIFFICULTIES_TEXT_COLOR[difficulty]

  end

end
