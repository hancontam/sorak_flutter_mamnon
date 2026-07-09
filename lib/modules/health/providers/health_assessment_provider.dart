import '../../../core/providers/crud_provider.dart';
import '../models/health_assessment.dart';
import '../repositories/health_assessment_repository.dart';

class HealthAssessmentProvider extends CrudProvider<HealthAssessment> {
  HealthAssessmentProvider({
    required HealthAssessmentRepository healthAssessmentRepository,
  }) : super(repository: healthAssessmentRepository);
}
