<?php

declare(strict_types=1);

namespace App\Command;

use Spiral\Goridge\RPC\RPC;
use Spiral\RoadRunner\Services\Manager;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\Table;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'app:rr',
    description: 'Add a short description for your command',
)]
class RrCommand extends Command
{
    private Manager $manager;

    public function __construct()
    {
        parent::__construct();

        $this->manager = new Manager(RPC::create('tcp://127.0.0.1:6001'));
    }

    public function __invoke(OutputInterface $output): int
    {
        $result = [];
        $table = new Table($output);

        $table->setHeaders(['Command', 'Memory', 'Error']);

        foreach ($this->manager->list() as $serviceGroupName) {
            foreach ($this->manager->statuses($serviceGroupName) as $serviceInstance) {
                $result[] = [
                    'command' => $serviceGroupName,
                    'memory' => $serviceInstance['memory_usage'],

                    'error' => !empty($serviceInstance['error'])
                        ? $serviceInstance['error']['message']
                        : null,
                ];
            }
        }

        $table->setRows($result);
        $table->render();

        return Command::SUCCESS;
    }
}
