<?php

declare(strict_types=1);

namespace App\Maker\Bundle;

use Symfony\Bundle\MakerBundle\ConsoleStyle;
use Symfony\Bundle\MakerBundle\DependencyBuilder;
use Symfony\Bundle\MakerBundle\Generator;
use Symfony\Bundle\MakerBundle\InputConfiguration;
use Symfony\Bundle\MakerBundle\Maker\AbstractMaker;
use Symfony\Bundle\MakerBundle\Str;
use Symfony\Bundle\MakerBundle\Util\UseStatementGenerator;
use Symfony\Component\Config\Definition\Builder\TreeBuilder;
use Symfony\Component\Config\Definition\ConfigurationInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\HttpKernel\Bundle\Bundle;

final class BundleMaker extends AbstractMaker
{
    private Filesystem $fs;
    private string $srcDir;

    public function __construct()
    {
        $this->fs = new Filesystem();
        $this->srcDir = dirname(__DIR__);
    }

    public static function getCommandName(): string
    {
        return 'make:bundle';
    }

    public static function getCommandDescription(): string
    {
        return 'Create a new bundle';
    }

    public function configureCommand(Command $command, InputConfiguration $inputConfig): void
    {
        $command
            ->addArgument(
                name: 'name',
                mode: InputArgument::OPTIONAL,
                description: sprintf(
                    'Choose a bundle name (e.g. <fg=yellow>%sBundle</>)',
                    Str::asClassName(
                        Str::getRandomTerm()
                    )
                )
            );
    }

    public function configureDependencies(DependencyBuilder $dependencies): void
    {
    }

    private function createBundleFile(Generator $generator, string $bundleName): void
    {
        $commandClassNameDetails = $generator->createClassNameDetails(
            name: $bundleName,
            namespacePrefix: $bundleName,
        );

        $useStatements = new UseStatementGenerator([
            Bundle::class,
        ]);

        $generator->generateClass(
            className: $commandClassNameDetails->getFullName(),
            templateName: "$this->srcDir/Bundle/Bundle.tpl.php",
            variables: [
                'class_name' => $bundleName,
                'use_statements' => $useStatements,
                'bundle_configuration_root' => Str::asSnakeCase($bundleName),
            ]
        );

        $generator->writeChanges();
    }

    private function createConfigurationFile(Generator $generator, string $bundleName): void
    {
        $commandClassNameDetails = $generator->createClassNameDetails(
            name: 'Configuration',
            namespacePrefix: "$bundleName\DependencyInjection",
        );

        $useStatements = new UseStatementGenerator([
            TreeBuilder::class,
            ConfigurationInterface::class,
        ]);

        $generator->generateClass(
            className: $commandClassNameDetails->getFullName(),
            templateName: "$this->srcDir/Bundle/Configuration.tpl.php",
            variables: [
                'class_name' => $bundleName,
                'use_statements' => $useStatements,
                'bundle_configuration_root' => Str::asSnakeCase($bundleName),
            ]
        );

        $generator->writeChanges();
    }

    public function generate(InputInterface $input, ConsoleStyle $io, Generator $generator): void
    {
        $bundleName = ucfirst(
            trim($input->getArgument('name'))
        );

        if (!str_ends_with($bundleName, 'Bundle')) {
            $bundleName = "{$bundleName}Bundle";
        }

        if ($this->fs->exists("$this->srcDir/$bundleName")) {
            throw new \Exception('Bundle already exists');
        }

        $this->createBundleFile($generator, $bundleName);
        $this->createConfigurationFile($generator, $bundleName);
        $this->writeSuccessMessage($io);
    }
}
