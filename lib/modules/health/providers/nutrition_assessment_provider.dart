import '../../../core/providers/crud_provider.dart';
import '../models/nutrition_assessment.dart';
import '../repositories/nutrition_assessment_repository.dart';

class NutritionAssessmentProvider extends CrudProvider<NutritionAssessment> {
  NutritionAssessmentProvider({
    required NutritionAssessmentRepository nutritionAssessmentRepository,
  }) : super(repository: nutritionAssessmentRepository);
}
