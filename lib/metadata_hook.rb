class RMetadataHook < Mumukit::Hook
  def metadata
    {language: {
        name: 'r',
        icon: {type: 'devicon', name: 'r'},
        version: '3.6.1',
        extension: 'R',
        ace_mode: 'R'
    },
     test_framework: {
         name: 'testthat',
         version: '2.3.1', # FIXME fix version using devtools
         test_extension: '.R',
         template: <<R
test_that("{{ test_template_sample_description }}", {
  expect_that( TRUE, is_true() )
})
R
     }}
  end
end



