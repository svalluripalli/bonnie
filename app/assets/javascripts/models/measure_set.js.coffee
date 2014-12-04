class Thorax.Models.MeasureSet extends Thorax.Model
  idAttribute: '_id'

class Thorax.Collections.MeasureSets extends Thorax.Collection
  url: 'complexity_dashboard/measure_sets'
  model: Thorax.Models.MeasureSet

class Thorax.Models.MeasurePair extends Thorax.Model
  # Transform data to something appropriate for the D3 visualization
  complexityVizData: ->
    measure1 = @get('measure_1')
    complexity1 = @overallComplexity('measure_1')
    measure2 = @get('measure_2')
    complexity2 = @overallComplexity('measure_2')
    name: measure2.cms_id
    complexity: complexity2
    change: complexity2 - complexity1

  # Get the overall complexity score for one of the two measures in the pair
  overallComplexity: (measure) ->
    complexity = @get(measure).complexity
    scores = _(complexity.populations).pluck('complexity')
    scores = scores.concat _(complexity.variables).pluck('complexity')
    _(scores).max()

class Thorax.Collections.MeasurePairs extends Thorax.Collection
  url: -> "complexity_dashboard/measure_sets/#{@measureSet1},#{@measureSet2}"
  model: Thorax.Models.MeasurePair
  initialize: (_, options) ->
    @measureSet1 = options.measureSet1
    @measureSet2 = options.measureSet2
  complexityVizData: -> @map (pair) -> pair.complexityVizData()
