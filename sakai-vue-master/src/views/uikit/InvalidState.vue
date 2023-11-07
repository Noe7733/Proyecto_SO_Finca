<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();

const productDialog = ref(false);

const openWindow = () => {
    productDialog.value = true;
};

</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h3>Lavado</h3>
                <Toast />
                <Toolbar class="mb-4">
                    <template v-slot:start>
                        <div class="my-2">
                            <Button label="Iniciar Lavado" icon="pi pi-plus" class="p-button-success mr-2"
                                @click="openWindow" />
                        </div>
                    </template>
                    <template v-slot:end>
                        <span class="p-input-icon-left mb-2">
                            <i class="pi pi-search" />
                            <InputText placeholder="Codigo de lavado" style="width: 100%" />
                        </span>
                    </template>
                </Toolbar>

                <DataTable class="p-datatable-gridlines" :paginator="true" :rows="10"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    :rowsPerPageOptions="[5, 10, 25]"
                    currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes en lavado"
                    responsiveLayout="scroll">
                    <Column field="" header="Codigo de Lavado" :sortable="true" style="width:50px"></Column>
                    <Column field="" header="Fecha" style="width:100px"></Column>
                    <Column field="" header="Hora" style="width:120px"></Column>
                    <Column field="" header="Kg ingresados" style="width:120px"></Column>
                    <Column field="" header="Status" style="width:170px"></Column>
                    <Column style="width:180px">
                        <template #header>
                            Acciones
                        </template>
                        <template #body="slotProps">
                            <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"></Button>
                            <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1"></Button>
                        </template>
                    </Column>
                </DataTable>
                <Dialog v-model:visible="productDialog" :style="{ width: '450px' }" header="Proceso de lavado" :modal="true"
                    class="p-fluid"></Dialog>
            </div>
        </div>
    </div>
</template>
