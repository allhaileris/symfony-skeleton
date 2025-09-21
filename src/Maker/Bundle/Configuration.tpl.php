<?= "<?php\n"; ?>

declare(strict_types=1);

namespace <?= $namespace; ?>;

<?= $use_statements; ?>

final class <?= $class_name; ?> implements ConfigurationInterface
{
    public function getConfigTreeBuilder(): TreeBuilder
    {
        $treeBuilder = new TreeBuilder('<?= $bundle_configuration_root; ?>');

        $treeBuilder->getRootNode()
        ->end();

        return $treeBuilder;
    }
}
