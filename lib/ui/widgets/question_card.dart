import 'package:flutter/material.dart';
import '../../data/models/question_model.dart';

/// Widget pour afficher une question avec ses choix de réponse
class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int? selectedChoiceId;
  final Function(int)? onAnswerSelected;
  final bool showCorrectAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedChoiceId,
    this.onAnswerSelected,
    this.showCorrectAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Texte de la question
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Instructions
        if (!showCorrectAnswer)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Sélectionnez votre réponse :',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Choix de réponse
        ...question.choices.map((choice) {
          final isSelected = selectedChoiceId == choice.id;
          final isCorrect = choice.isCorrect;

          Color? backgroundColor;
          Color? borderColor;
          IconData? icon;
          Color? iconColor;

          if (showCorrectAnswer) {
            if (isCorrect) {
              // Bonne réponse
              backgroundColor = Colors.green.withOpacity(0.1);
              borderColor = Colors.green;
              icon = Icons.check_circle;
              iconColor = Colors.green;
            } else if (isSelected && !isCorrect) {
              // Mauvaise réponse sélectionnée
              backgroundColor = Colors.red.withOpacity(0.1);
              borderColor = Colors.red;
              icon = Icons.cancel;
              iconColor = Colors.red;
            }
          } else if (isSelected) {
            // Réponse sélectionnée (avant validation)
            backgroundColor = Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1);
            borderColor = Theme.of(context).colorScheme.primary;
            icon = Icons.radio_button_checked;
            iconColor = Theme.of(context).colorScheme.primary;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: onAnswerSelected != null && !showCorrectAnswer
                  ? () => onAnswerSelected!(choice.id!)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(
                    color: borderColor ?? Colors.grey.shade300,
                    width: borderColor != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Icône de sélection/validation
                    if (icon != null) ...[
                      Icon(icon, color: iconColor, size: 24),
                      const SizedBox(width: 12),
                    ] else ...[
                      Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Texte du choix
                    Expanded(
                      child: Text(
                        choice.choiceText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected || (showCorrectAnswer && isCorrect)
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: showCorrectAnswer && !isCorrect && isSelected
                              ? Colors.red.shade700
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
