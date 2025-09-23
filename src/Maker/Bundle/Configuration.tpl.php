<?php echo "<?php\n"; ?>

declare(strict_types=1);

namespace <?php echo $namespace; ?>;

<?php echo $use_statements; ?>

final class <?php echo $class_name; ?> implements ConfigurationInterface
{
    public function getConfigTreeBuilder(): TreeBuilder
    {
        $treeBuilder = new TreeBuilder('<?php echo $bundle_configuration_root; ?>');

        $treeBuilder->getRootNode()
        ->end();

        return $treeBuilder;
    }
}
