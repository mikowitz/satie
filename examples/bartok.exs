defmodule Satie.Examples.Bartok do
  import Satie
  alias Satie.{Command, Container, Measure, Note, Score, Staff, StaffGroup, Voice}

  def build_score do
    score = Score.new([
      StaffGroup.new([
        upper_staff(),
        lower_staff()
        |> update_in([3, 0, 0], fn n -> Satie.attach(n, Command.new("voiceOne")) end)
        |> update_in([4, 0, 0], fn n -> Satie.attach(n, Command.new("voiceOne")) end)
        |> update_in([3, 1, 0], fn n -> Satie.attach(n, Command.new("voiceTwo")) end)
        |> update_in([4, 1, 0], fn n -> Satie.attach(n, Command.new("voiceTwo")) end)
      ], name: "Piano")
    ])
  end

  def upper_staff do
    Staff.new([
      Measure.new("{ \\time 2/4 a'8 g'8 f'8 e'8 }"),
      Measure.new("{ \\time 3/4 d'4 g'8 f'8 e'8 d'8 }"),
      Measure.new("{ \\time 2/4 c'8 d'16 e'16 f'8 e'8 }"),
      Measure.new("{ \\time 2/4 d'2 }"),
      Measure.new("{ \\time 2/4 d'2 }")
    ], name: "Upper_Staff")
  end

  def lower_staff do
    Staff.new([
      Measure.new("{ \\time 2/4 b4 d'8 c'8 }"),
      Measure.new("{ \\time 3/4 b8 a8 af4 c'8 bf8 }"),
      Measure.new("{ \\time 2/4 a8 g8 fs8 g16 a16 }"),
      Container.new([
        Voice.new([
          Note.new("b2")
        ], name: "Upper Voice"),
        Voice.new([
          Note.new("b4"), Note.new("a4")
        ], name: "Lower Voice")
      ], simultaneous: true),
      Container.new([
        Voice.new([
          Note.new("b2")
        ], name: "Upper Voice"),
        Voice.new([
          Note.new("g2")
        ], name: "Lower Voice")
      ], simultaneous: true)
    ], name: "Lower_Staff")
  end
end
