module ApplicationHelper
  
  DIFFICULTY_CLASS = {
    text:  {EASY: 'text-info',  NORMAL: 'text-success',  HARD: 'text-warning',  EXTREME: 'text-danger'},
    label: {EASY: 'label-info', NORMAL: 'label-success', HARD: 'label-warning', EXTREME: 'label-danger'},
    table: {EASY: 'info',       NORMAL: 'success',       HARD: 'warning',       EXTREME: 'error'},
  }

  def get_difficulty_text(difficulty)
    get_difficulty_class(:text, difficulty)
  end

  def get_difficulty_label(difficulty)
    get_difficulty_class(:label, difficulty)
  end

  def get_difficulty_table(difficulty)
    get_difficulty_class(:table, difficulty)
  end

  private def get_difficulty_class(class_key, difficulty)
    DIFFICULTY_CLASS[class_key][difficulty.intern]
  end

end
