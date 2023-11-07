<script setup>
import { ref } from 'vue';

import AppMenuItem from './AppMenuItem.vue';

const model = ref([
    {
        label: 'Menú',
        items: [
            { label: 'Dashboard', icon: 'pi pi-fw pi-home', to: '/' },
            { label: 'Lotes de café', icon:'pi pi-fw pi-box', to: '/uikit/message'}
        ]
    },
    {
        label: 'Proceso de café',
        items: [
            { label: 'Recolección', icon: 'pi pi-fw pi-inbox', to: '/uikit/formlayout' },
            { label: 'Despulpado', icon: 'pi pi-fw pi-filter', to: '/uikit/input' },
            { label: 'Fermentación', icon: 'pi pi-fw pi-stop', to: '/uikit/floatlabel' },
            { label: 'Lavado', icon: 'pi pi-fw pi-cloud', to: '/uikit/invalidstate' },
            { label: 'Secado', icon: 'pi pi-fw pi-sun', to: '/uikit/button', class: 'rotated-icon' },
            { label: 'Reportes', icon: 'pi pi-fw pi-file', to: '/uikit/table' },
            { label: 'Usuarios', icon: 'pi pi-fw pi-users', to: '/uikit/list' }
        ]
    },
    {
        label: 'Pages',
        icon: 'pi pi-fw pi-briefcase',
        to: '/pages',
        items: [
            {
                label: 'Auth',
                icon: 'pi pi-fw pi-user',
                items: [
                    {
                        label: 'Login',
                        icon: 'pi pi-fw pi-sign-in',
                        to: '/auth/login'
                    },
                    {
                        label: 'Error',
                        icon: 'pi pi-fw pi-times-circle',
                        to: '/auth/error'
                    },
                    {
                        label: 'Access Denied',
                        icon: 'pi pi-fw pi-lock',
                        to: '/auth/access'
                    }
                ]
            },
            {
                label: 'Crud',
                icon: 'pi pi-fw pi-pencil',
                to: '/pages/crud'
            }
        ]
    }
]);
</script>

<template>
    <ul class="layout-menu">
        <template v-for="(item, i) in model" :key="item">
            <app-menu-item v-if="!item.separator" :item="item" :index="i"></app-menu-item>
            <li v-if="item.separator" class="menu-separator"></li>
        </template>
    </ul>
</template>

<style lang="scss" scoped></style>
